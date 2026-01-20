unit uObfuscatingEncoder;

interface

uses
  System.Classes, System.SysUtils, SecurePRNG;

type
  TObfuscatingEncoder = class
  private
    FPRNG: TSecurePRNG;

    function ByteAdd(A, B: Byte): Byte;
    function ByteSub(C, B: Byte): Byte;
    function ByteXor(A, B: Byte): Byte;
    function ByteNot(A: Byte): Byte;
    function ByteRol(Value: Byte; Shift: Byte): Byte;
    function ByteRor(Value: Byte; Shift: Byte): Byte;
    function ByteSwap(Value: Byte; Shift : Byte): Byte;
  public
    constructor Create(APRNG: TSecurePRNG);
    destructor Destroy; override;

    function EncryptStream(Input: TMemoryStream): TStringStream;
    function DecryptStream(Input: TStringStream): TMemoryStream;
  end;

implementation

{ TObfuscatingEncoder }

constructor TObfuscatingEncoder.Create(APRNG: TSecurePRNG);
begin
  inherited Create;
  FPRNG := APRNG;
end;

destructor TObfuscatingEncoder.Destroy;
begin
  inherited;
end;

function TObfuscatingEncoder.ByteAdd(A, B: Byte): Byte;
begin
  Result := (A + B) and $FF;
end;

function TObfuscatingEncoder.ByteSub(C, B: Byte): Byte;
begin
  Result := (C - B) and $FF;
end;

function TObfuscatingEncoder.ByteSwap(Value: Byte; Shift : Byte): Byte;
begin
  Result := ((Value and $0F) shl 4) or ((Value and $F0) shr 4);
end;

function TObfuscatingEncoder.ByteXor(A, B: Byte): Byte;
begin
  Result := A xor B;
end;

function TObfuscatingEncoder.ByteNot(A: Byte): Byte;
begin
  Result := not A;
end;

function TObfuscatingEncoder.ByteRol(Value: Byte; Shift: Byte): Byte;
begin
  Shift := Shift and 7;
  if Shift = 0
    then Result := Value
    else Result := ((Value shl Shift) or (Value shr (8 - Shift))) and $FF;
end;


function TObfuscatingEncoder.ByteRor(Value: Byte; Shift: Byte): Byte;
begin
  Shift := Shift and 7;
  if Shift = 0
    then Result := Value
    else Result := ((Value shr Shift) or (Value shl (8 - Shift))) and $FF;
end;

function TObfuscatingEncoder.EncryptStream(Input: TMemoryStream): TStringStream;
var
  Data: TBytes;
  i: Integer;
  b: Byte;
  OpIndex: Byte;
begin
  if Input.Size = 0 then Exit;
  Result := TStringStream.Create('', TEncoding.ASCII);

  SetLength(Data, Input.Size);
  Input.Position := 0;
  Input.ReadBuffer(Data[0], Input.Size);

  for i := 0 to High(Data) do
  begin
    b := Data[i];

    OpIndex := FPRNG.Randome;
    if (OpIndex and $0F) = 0
       then FPRNG.Position := FPRNG.Position + FPRNG.Randome;

    OpIndex := FPRNG.Randome and 7;
    case OpIndex of
      0: b := ByteAdd(b, FPRNG.Randome);
      1: b := ByteSub(b, FPRNG.Randome);
      2: b := ByteXor(b, FPRNG.Randome);
      3: b := ByteNot(b xor FPRNG.Randome);
      4: b := ByteRol(b, FPRNG.Randome);
      5: b := ByteRor(b, FPRNG.Randome);
      6: b := ByteXor(b, FPRNG.Randome);
      7: b := ByteSwap(b, FPRNG.Randome);
    end;

    Result.WriteString(b.ToHexString(2));
  end;
end;

function TObfuscatingEncoder.DecryptStream(Input: TStringStream): TMemoryStream;
var
  HexStr: string;
  Data: TBytes;
  i, Len: Integer;
  b: Byte;
  OpIndex: Byte;
begin
  Result := TMemoryStream.Create;

  if Input.Size = 0 then
    Exit;

  HexStr := Input.DataString;
  Len := Length(HexStr);

  if (Len = 0) or (Len mod 2 <> 0) then
    raise Exception.Create('Invalid hex stream');

  SetLength(Data, Len div 2);

  for i := 0 to High(Data) do
  begin
    var HexPair := Copy(HexStr, i * 2 + 1, 2);
    try
      b := StrToInt('$' + HexPair);
    except
      raise Exception.Create('Invalid hex char at position ' + IntToStr(i * 2 + 1));
    end;

    OpIndex := FPRNG.Randome;
    if (OpIndex and $0F) = 0
       then FPRNG.Position := FPRNG.Position + FPRNG.Randome;

    OpIndex := FPRNG.Randome and 7;
    case OpIndex of
      0: b := ByteSub(b, FPRNG.Randome);
      1: b := ByteAdd(b, FPRNG.Randome);
      2: b := ByteXor(b, FPRNG.Randome);
      3: b := (ByteNot(b)) xor FPRNG.Randome;
      4: b := ByteRor(b, FPRNG.Randome);
      5: b := ByteRol(b, FPRNG.Randome);
      6: b := ByteXor(b, FPRNG.Randome);
      7: b := ByteSwap(b, FPRNG.Randome);
    end;

    Data[i] := b;
  end;

  Result.WriteBuffer(Data[0], Length(Data));
  Result.Position := 0;
end;

end.
