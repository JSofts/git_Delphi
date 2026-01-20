program FlyEvent;

uses
  Vcl.Forms,
  fmFlyEvent in 'fmFlyEvent.pas' {FlyEventForm},
  SecurePRNG in 'SecurePRNG.pas',
  uObfuscatingEncoder in 'uObfuscatingEncoder.pas',
  uFlyEventProtocol in 'uFlyEventProtocol.pas',
  uProtocolEvents in 'uProtocolEvents.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFlyEventForm, FlyEventForm);
  Application.Run;
end.
