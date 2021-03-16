object Form1: TForm1
  Left = 1461
  Top = 812
  BorderStyle = bsDialog
  Caption = 'Cookie Feeder'
  ClientHeight = 121
  ClientWidth = 406
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMinimized
  OnClose = hideit
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 328
    Top = 8
    Width = 73
    Height = 41
    Caption = 'OK'
    TabOrder = 0
    OnClick = formhide
  end
  object Button2: TButton
    Left = 328
    Top = 48
    Width = 73
    Height = 41
    Caption = 'More'
    TabOrder = 1
    OnClick = readcookie
  end
  object Button3: TButton
    Left = 328
    Top = 88
    Width = 73
    Height = 25
    Caption = 'Cookie file...'
    TabOrder = 2
    WordWrap = True
    OnClick = opendialog
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 313
    Height = 105
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object PopupMenu1: TPopupMenu
    Left = 256
    Top = 8
    object N11: TMenuItem
      Caption = 'About'
      OnClick = AboutClick
    end
    object Runonstartup1: TMenuItem
      Caption = 'Run on startup'
      Checked = True
      OnClick = Runonstartup1Click
    end
    object N21: TMenuItem
      Caption = 'Exit'
      OnClick = ExitClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 288
    Top = 8
  end
end
