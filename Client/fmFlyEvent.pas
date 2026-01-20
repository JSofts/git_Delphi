unit fmFlyEvent;

interface

uses
  Winapi.Windows, Winapi.Messages,

  System.SysUtils, System.Variants, System.Classes,

  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  SecurePRNG, uObfuscatingEncoder, Vcl.TitleBarCtrls, Vcl.ToolWin, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls,
  System.Actions, Vcl.ActnList, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TFlyEventForm = class(TForm)
    StatusBar1: TStatusBar;
    ActionManager1: TActionManager;
    ActionMainMenuBar1: TActionMainMenuBar;
    Splitter1: TSplitter;
    pnChats: TPanel;
    Panel1: TPanel;
    TreeView1: TTreeView;
    ListBox1: TListBox;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    pnWrite: TPanel;
    edMessage: TEdit;
    btnSend: TButton;
    Memo1: TMemo;
    pnEvents: TPanel;
    pnButtons: TPanel;
    btnCreate: TButton;
    btnDelete: TButton;
    btnAproved: TButton;
    ScrollBox1: TScrollBox;
    Panel3: TPanel;
    procedure pnWriteCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FlyEventForm: TFlyEventForm;

implementation

{$R *.dfm}

{ TFlyEventForm }

procedure TFlyEventForm.pnWriteCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  edMessage.Width := NewWidth - 35;
end;

end.
