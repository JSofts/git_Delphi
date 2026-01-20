unit uProtocolEvents;

interface

uses
  System.Classes, System.SysUtils;

type
  TProtocolEventKind = (pekAuthResult, pekChatMessage, pekEventList, pekError);

  TProtocolEvent = class
  public
    Kind: TProtocolEventKind;
    constructor Create(AKind: TProtocolEventKind);
  end;

  TAuthResultEvent = class(TProtocolEvent)
  public
    Success: Boolean;
    Message: string;
    constructor Create(ASuccess: Boolean; const AMsg: string);
  end;

  TChatMessageEvent = class(TProtocolEvent)
  public
    From: string;          // Отправитель (например, "Igor", "Admin", "System")
    ToUser: string;        // Упоминание или получатель ЛС (может быть пустым)
    ToRooms: string;       // Список комнат через запятую: "UUEE,USSS,UAAA"
    Channel: string;       // Канал (например, "events"); игнорируется, если ToRooms <> ''
    Room: string;          // Конкретная комната; игнорируется, если ToRooms <> ''
    IsBroadcast: Boolean;  // Глобальное сообщение для всех
    Text: string;
    Timestamp: TDateTime;

    constructor Create(
      const AFrom, AToUser, AToRooms, AChannel, ARoom, AText: string;
      ABroadcast: Boolean;
      ATimestamp: TDateTime
    );
  end;

implementation

{ TProtocolEvent }

constructor TProtocolEvent.Create(AKind: TProtocolEventKind);
begin
  inherited Create;
  Kind := AKind;
end;

{ TAuthResultEvent }

constructor TAuthResultEvent.Create(ASuccess: Boolean; const AMsg: string);
begin
  inherited Create(pekAuthResult);
  Success := ASuccess;
  Message := AMsg;
end;

{ TChatMessageEvent }

constructor TChatMessageEvent.Create(
  const AFrom, AToUser, AToRooms, AChannel, ARoom, AText: string;
  ABroadcast: Boolean;
  ATimestamp: TDateTime
);
begin
  inherited Create(pekChatMessage);
  From := AFrom;
  ToUser := AToUser;
  ToRooms := AToRooms;
  Channel := AChannel;
  Room := ARoom;
  IsBroadcast := ABroadcast;
  Text := AText;
  Timestamp := ATimestamp;
end;

end.
