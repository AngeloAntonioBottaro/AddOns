object ViewPrincipal: TViewPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'AddOns'
  ClientHeight = 159
  ClientWidth = 439
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
    Width = 433
    Height = 134
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
  object ImgClose: TImage
    Left = 392
    Top = 3
    Width = 47
    Height = 41
    Cursor = crNo
    OnClick = ImgCloseClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 140
    Width = 439
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object TimerShow: TTimer
    Enabled = False
    OnTimer = TimerShowTimer
    Left = 24
    Top = 16
  end
end
