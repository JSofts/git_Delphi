object FlyEventForm: TFlyEventForm
  Left = 449
  Top = 228
  Caption = 'Fly Event'
  ClientHeight = 478
  ClientWidth = 764
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  StyleElements = [seFont]
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 520
    Top = 29
    Height = 430
    Align = alRight
    ExplicitLeft = 488
    ExplicitTop = 176
    ExplicitHeight = 100
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 459
    Width = 764
    Height = 19
    Panels = <
      item
        Text = 'offline'
        Width = 50
      end
      item
        Width = 50
      end>
    ExplicitTop = 451
    ExplicitWidth = 760
  end
  object ActionMainMenuBar1: TActionMainMenuBar
    Left = 0
    Top = 0
    Width = 764
    Height = 29
    UseSystemFont = False
    Caption = 'ActionMainMenuBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 10461087
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Spacing = 0
    ExplicitWidth = 760
  end
  object pnChats: TPanel
    Left = 523
    Top = 29
    Width = 241
    Height = 430
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 519
    ExplicitHeight = 422
    object Splitter3: TSplitter
      Left = 1
      Top = 201
      Width = 239
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitWidth = 224
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 239
      Height = 200
      Align = alTop
      TabOrder = 0
      object Splitter2: TSplitter
        Left = 122
        Top = 1
        Height = 198
        ExplicitLeft = 136
        ExplicitTop = 16
        ExplicitHeight = 100
      end
      object TreeView1: TTreeView
        Left = 1
        Top = 1
        Width = 121
        Height = 198
        Align = alLeft
        Indent = 19
        TabOrder = 0
      end
      object ListBox1: TListBox
        Left = 125
        Top = 1
        Width = 113
        Height = 198
        Align = alClient
        ItemHeight = 15
        TabOrder = 1
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 204
      Width = 239
      Height = 225
      Align = alClient
      TabOrder = 1
      ExplicitHeight = 217
      object pnWrite: TPanel
        Left = 1
        Top = 183
        Width = 237
        Height = 41
        Align = alBottom
        TabOrder = 0
        OnCanResize = pnWriteCanResize
        ExplicitTop = 175
        DesignSize = (
          237
          41)
        object edMessage: TEdit
          Left = 4
          Top = 10
          Width = 182
          Height = 23
          TabOrder = 0
        end
        object btnSend: TButton
          Left = 200
          Top = 9
          Width = 25
          Height = 25
          Anchors = [akTop, akRight]
          Caption = '>>'
          Default = True
          TabOrder = 1
        end
      end
      object Memo1: TMemo
        Left = 1
        Top = 1
        Width = 237
        Height = 182
        Align = alClient
        TabOrder = 1
        ExplicitHeight = 174
      end
    end
  end
  object pnEvents: TPanel
    Left = 0
    Top = 29
    Width = 520
    Height = 430
    Align = alClient
    TabOrder = 3
    ExplicitWidth = 516
    ExplicitHeight = 422
    object pnButtons: TPanel
      Left = 1
      Top = 1
      Width = 518
      Height = 41
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 514
      object btnCreate: TButton
        Left = 8
        Top = 8
        Width = 75
        Height = 25
        Caption = #1057#1086#1079#1076#1072#1090#1100
        TabOrder = 0
      end
      object btnDelete: TButton
        Left = 96
        Top = 8
        Width = 75
        Height = 25
        Caption = #1059#1076#1072#1083#1080#1090#1100
        TabOrder = 1
      end
      object btnAproved: TButton
        Left = 185
        Top = 8
        Width = 75
        Height = 25
        Caption = #1059#1090#1074#1077#1088#1076#1080#1090#1100
        TabOrder = 2
      end
    end
    object ScrollBox1: TScrollBox
      Left = 1
      Top = 42
      Width = 518
      Height = 387
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 514
      ExplicitHeight = 379
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 514
        Height = 383
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 510
        ExplicitHeight = 375
      end
    end
  end
  object ActionManager1: TActionManager
    Left = 416
    Top = 280
    StyleName = 'Platform Default'
  end
  object PopupMenu1: TPopupMenu
    Left = 328
    Top = 227
  end
end
