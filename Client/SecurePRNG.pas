unit SecurePRNG;

interface

uses
  System.SysUtils;

type
  TSecurePRNG = class
  private
    FPosition: Cardinal;
    FSeed: UInt64;

    function CicleRoll(Value : UInt64; Step : Byte): Uint64;
    procedure SetSeed(const Value: UInt64);
  public
    property Position: Cardinal read FPosition write FPosition;

    property Seed: UInt64 read FSeed write SetSeed;
    procedure Initiate;
    function Randome: Byte;
  end;

implementation

{ TSecurePRNG }

function TSecurePRNG.CicleRoll(Value: UInt64; Step: Byte): Uint64;
begin
  {$IFOPT R+}{$DEFINE R_OFF}{$R-}{$ENDIF}
  {$IFOPT Q+}{$DEFINE Q_OFF}{$Q-}{$ENDIF}

  var rl : Byte := 64 - Step;
  Result := (Value shr Step) and (Value shl rl);

  {$IFDEF R_OFF}{$R+}{$UNDEF R_OFF}{$ENDIF}
  {$IFDEF Q_OFF}{$Q+}{$UNDEF Q_OFF}{$ENDIF}
end;

procedure TSecurePRNG.Initiate;
begin
  Randomize;
  FPosition := Random(Integer.MaxValue); // случайная позиция < 2^31
end;

function TSecurePRNG.Randome: Byte;
var
  x: UInt64;
begin
  {$IFOPT R+}{$DEFINE R_OFF}{$R-}{$ENDIF}
  {$IFOPT Q+}{$DEFINE Q_OFF}{$Q-}{$ENDIF}

  x := FSeed xor UInt64(FPosition);

  // --- Мощный микс ---
  x := x xor CicleRoll(x, 32);
  x := x * $4F1BBCDCBFA77A9D; // простое число
  x := x xor CicleRoll(x, 32);
  x := x * $632BEC73D1A13A81; // другое простое
  x := x xor CicleRoll(x, 32);

  // --- Извлекаем байт НЕ из фиксированной позиции ---
  // А из позиции, зависящей от младших битов Position
  Result := $FF and (x shr 56);
  FPosition :=x;
  {$IFDEF R_OFF}{$R+}{$UNDEF R_OFF}{$ENDIF}
  {$IFDEF Q_OFF}{$Q+}{$UNDEF Q_OFF}{$ENDIF}
end;

procedure TSecurePRNG.SetSeed(const Value: UInt64);
var
  k, p : UInt64;
begin
  FSeed := Value;

  p := (Fseed shr 7) and $FFFFFF;
  FPosition := p;
  k:= (((Randome shl 8) + Randome) shl 8) + Randome;
  p := p xor k;
  FPosition := p;
end;

end.
