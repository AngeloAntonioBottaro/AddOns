object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'AddOns'
  ClientHeight = 61
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbNome: TLabel
    Left = 0
    Top = 0
    Width = 370
    Height = 33
    Align = alTop
    Alignment = taCenter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitWidth = 8
  end
  object Memo1: TMemo
    Left = 44
    Top = 8
    Width = 49
    Height = 25
    TabOrder = 0
    Visible = False
    WordWrap = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 42
    Width = 370
    Height = 19
    Panels = <
      item
        Width = 50
      end>
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
