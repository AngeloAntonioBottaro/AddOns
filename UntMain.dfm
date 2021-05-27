object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'AddOns'
  ClientHeight = 134
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbNome: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 381
    Height = 87
    Align = alClient
    Alignment = taCenter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
    ExplicitWidth = 8
    ExplicitHeight = 33
  end
  object BtnFechar: TImage
    Left = 354
    Top = 8
    Width = 25
    Height = 25
    Cursor = crNo
    OnClick = BtnFecharClick
  end
  object Memo1: TMemo
    Left = 0
    Top = 93
    Width = 387
    Height = 11
    Align = alBottom
    TabOrder = 0
    Visible = False
    WordWrap = False
    ExplicitTop = 104
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 115
    Width = 387
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object mmLinks: TMemo
    Left = 0
    Top = 104
    Width = 387
    Height = 11
    Align = alBottom
    TabOrder = 2
    Visible = False
    WordWrap = False
    ExplicitTop = 112
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
  object OpenDialog: TOpenDialog
    Left = 112
    Top = 8
  end
end
