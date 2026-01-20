unit uFlyEventProtocol;

interface

uses
  System.Classes, System.SysUtils,
  IdTCPClient, IdGlobal, IdException,
  System.JSON, System.DateUtils,
  SecurePRNG, uObfuscatingEncoder, uProtocolEvents;

type

  TFlyEventProtocol = class(TObject)
  private
    FHost: string;
    FPort: Integer;
    FConnected: Boolean;
    FSessionKey: UInt64;
    FPRNG: TSecurePRNG;
    FEncoder: TObfuscatingEncoder;
    FClient: TIdTCPClient;
    FOnEvent: TProc<TProtocolEvent>;
    FReceiveThread: TThread;
    FStop: Boolean;

    procedure ReceiveLoop;
    procedure ProcessPacket(const ALine: string);
    procedure HandleAuthResponse(Json: TJSONObject);
    procedure HandleChatMessage(Json: TJSONObject);
    procedure HandleEventList(Json: TJSONObject);
    procedure HandleError(Json: TJSONObject);
  public
    constructor Create;
    destructor Destroy; override;

    property OnEvent: TProc<TProtocolEvent> read FOnEvent write FOnEvent;
    property Connected: Boolean read FConnected;

    function Connect(const AHost: string; APort: Integer): Boolean;
    procedure Disconnect;

    procedure Authenticate(const AUser, APasswordHash: string);
    procedure RequestEventList;
    procedure CreateEvent(const AEventJson: string);
    procedure Vote(EventID: Cardinal; Choice: string);
    procedure SendChatMessage(Channel, Room, Text: string);
  end;

implementation

{ TFlyEventProtocol }

constructor TFlyEventProtocol.Create;
begin
  inherited;
  FPRNG := TSecurePRNG.Create;
  FEncoder := TObfuscatingEncoder.Create(FPRNG);
  FClient := TIdTCPClient.Create(nil);
  FClient.ConnectTimeout := 5000;
  FClient.ReadTimeout := 30000;
end;

destructor TFlyEventProtocol.Destroy;
begin
  Disconnect;
  FClient.Free;
  FEncoder.Free;
  FPRNG.Free;
  inherited;
end;

function TFlyEventProtocol.Connect(const AHost: string; APort: Integer): Boolean;
begin
  if FConnected then
  begin
    Result := True;
    Exit;
  end;

  try
    FHost := AHost;
    FPort := APort;
    FClient.Host := AHost;
    FClient.Port := APort;
    FClient.Connect;
    FConnected := True;

    FStop := False;
    FReceiveThread := TThread.CreateAnonymousThread(
      procedure
      begin
        ReceiveLoop;
      end
    );
    FReceiveThread.Start;

    Result := True;
  except
    on E: Exception do
    begin
      FConnected := False;
      Result := False;
    end;
  end;
end;

procedure TFlyEventProtocol.Disconnect;
begin
  if not FConnected then Exit;
  FStop := True;
  FClient.Disconnect;
  if Assigned(FReceiveThread) then
  begin
    FReceiveThread.WaitFor;
    FreeAndNil(FReceiveThread);
  end;
  FConnected := False;
end;

procedure TFlyEventProtocol.Authenticate(const AUser, APasswordHash: string);
begin
  FClient.IOHandler.WriteLn('{"cmd":"auth","user":"' + AUser + '","pass_hash":"' + APasswordHash + '"}');
end;

procedure TFlyEventProtocol.RequestEventList;
begin
  FClient.IOHandler.WriteLn('{"cmd":"get_events"}');
end;

procedure TFlyEventProtocol.CreateEvent(const AEventJson: string);
begin
  FClient.IOHandler.WriteLn('{"cmd":"create_event",' + AEventJson + '}');
end;

procedure TFlyEventProtocol.Vote(EventID: Cardinal; Choice: string);
begin
  FClient.IOHandler.WriteLn(Format('{"cmd":"vote","event_id":%d,"choice":"%s"}', [EventID, Choice]));
end;

procedure TFlyEventProtocol.SendChatMessage(Channel, Room, Text: string);
begin
  FClient.IOHandler.WriteLn(Format('{"cmd":"chat","channel":"%s","room":"%s","text":"%s"}',
    [Channel, Room, Text]));
end;

procedure TFlyEventProtocol.ReceiveLoop;
var
  Line: string;
begin
  while not FStop do
  try
    Line := FClient.IOHandler.ReadLn;
    if Line = '' then Break;

    TThread.Synchronize(nil,
      procedure
      begin
        ProcessPacket(Line);
      end
    );
  except
    on E: EIdConnClosedGracefully do
      Break;
    on E: Exception do
      Break;
  end;

  TThread.Synchronize(nil,
    procedure
    begin
      if FConnected then
        Disconnect;
    end
  );
end;

procedure TFlyEventProtocol.ProcessPacket(const ALine: string);
var
  EncryptedStream: TStringStream;
  DecryptedStream: TMemoryStream;
  Buffer: TBytes;
  JsonStr: string;
  Json: TJSONObject;
begin
  try
    // Дешифровка
    EncryptedStream := TStringStream.Create(ALine);
    try
      DecryptedStream := FEncoder.DecryptStream(EncryptedStream);
      try
        SetLength(Buffer, DecryptedStream.Size);
        if DecryptedStream.Size > 0 then
          DecryptedStream.ReadBuffer(Buffer[0], Length(Buffer));
        JsonStr := TEncoding.UTF8.GetString(Buffer);
      finally
        DecryptedStream.Free;
      end;
    finally
      EncryptedStream.Free;
    end;

    // Парсинг
    Json := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
    try
      if Json.TryGetValue('cmd', JsonStr) then
      begin
        if JsonStr = 'auth_ok' then
          HandleAuthResponse(Json)
        else if JsonStr = 'chat' then
          HandleChatMessage(Json)
        else if JsonStr = 'event_list' then
          HandleEventList(Json)
        else if JsonStr = 'error' then
          HandleError(Json);
        // ... другие команды
      end;
    finally
      Json.Free;
    end;
  except
    // Игнорируем повреждённые пакеты
  end;
end;

procedure TFlyEventProtocol.HandleAuthResponse(Json: TJSONObject);
var
  Event: TAuthResultEvent;
  HexKey: string;
begin
  HexKey := Json.GetValue<string>('session_key');
  FSessionKey := UInt64(StrToInt64('$' + HexKey));
  FPRNG.Seed := FSessionKey; // ← через свойство, вызывает SetSeed

  if Assigned(FOnEvent) then
  begin
    Event := TAuthResultEvent.Create;
    Event.Success := True;
    Event.Message := 'OK';
    FOnEvent(Event);
  end;
end;

procedure TFlyEventProtocol.HandleChatMessage(Json: TJSONObject);
var
  Event: TChatMessageEvent;
begin
  if Assigned(FOnEvent) then
  begin
    Event := TChatMessageEvent.Create;
    Event.Channel := Json.GetValue<string>('channel');
    Event.Room := Json.GetValue<string>('room');
    Event.Sender := Json.GetValue<string>('user');
    Event.Text := Json.GetValue<string>('text');
    Event.Timestamp := UnixToDateTime(Json.GetValue<Int64>('ts'));
    FOnEvent(Event);
  end;
end;

procedure TFlyEventProtocol.HandleEventList(Json: TJSONObject);
begin
  // TODO: обработка списка событий
end;

procedure TFlyEventProtocol.HandleError(Json: TJSONObject);
begin
  // TODO: обработка ошибки
end;

end.
