object TCliente: TTCliente
  Left = 0
  Top = 0
  Align = alCustom
  ClientHeight = 542
  ClientWidth = 561
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LAB: TLabel
    Left = 232
    Top = 47
    Width = 10
    Height = 13
    Caption = 'N '
    Color = clRed
    ParentColor = False
  end
  object LAB1: TLabel
    Left = 248
    Top = 47
    Width = 17
    Height = 13
    Align = alCustom
    Caption = '= 0'
    Color = clRed
    ParentColor = False
  end
  object TDBText
    Left = 256
    Top = 280
    Width = 65
    Height = 17
  end
  object t: TPanel
    Left = 0
    Top = 0
    Width = 561
    Height = 73
    Align = alTop
    TabOrder = 0
  end
  object FOOTER: TPanel
    Left = 0
    Top = 477
    Width = 561
    Height = 65
    Align = alBottom
    TabOrder = 1
    object BitBtn4: TBitBtn
      Left = 248
      Top = -16
      Width = 75
      Height = 25
      Caption = 'BitBtn4'
      TabOrder = 0
    end
  end
  object DBNavigator1: TDBNavigator
    Left = 0
    Top = -2
    Width = 226
    Height = 73
    VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
    Align = alCustom
    TabOrder = 2
  end
  object MENU: TRadioGroup
    Left = 341
    Top = 0
    Width = 223
    Height = 81
    Align = alCustom
    TabOrder = 3
  end
  object RG: TDBGrid
    AlignWithMargins = True
    Left = 821
    Top = 1236
    Width = 578
    Height = 391
    Align = alCustom
    ParentColor = True
    TabOrder = 4
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object MAIN: TPanel
    Left = -22
    Top = 477
    Width = 578
    Height = 71
    Align = alCustom
    TabOrder = 5
  end
  object TEdit
    Left = 0
    Top = 472
    Width = 441
    Height = 21
    TabOrder = 6
  end
  object btnlimpar: TBitBtn
    Left = 447
    Top = 473
    Width = 75
    Height = 23
    Align = alCustom
    Caption = 'limpar'
    TabOrder = 7
  end
  object btntranferir: TBitBtn
    Left = 0
    Top = 509
    Width = 55
    Height = 25
    Caption = 'tranferir'
    TabOrder = 8
  end
  object btnConsultar: TBitBtn
    Left = 153
    Top = 511
    Width = 55
    Height = 25
    Align = alCustom
    Caption = 'consultar'
    TabOrder = 9
  end
  object btnName: TBitBtn
    Left = 248
    Top = 509
    Width = 75
    Height = 25
    Caption = 'editar'
    TabOrder = 10
  end
  object btnExcluir: TBitBtn
    Left = 344
    Top = 509
    Width = 75
    Height = 25
    Caption = 'excluir'
    TabOrder = 11
  end
  object btnSair: TBitBtn
    Left = 447
    Top = 511
    Width = 75
    Height = 23
    Caption = 'sair'
    TabOrder = 12
  end
  object BTN: TRadioButton
    Left = 341
    Top = 46
    Width = 113
    Height = 17
    Caption = 'ATIVO'
    TabOrder = 13
  end
  object BTN1: TRadioButton
    Left = 409
    Top = 46
    Width = 104
    Height = 17
    Align = alCustom
    Caption = 'INATIVO'
    TabOrder = 14
  end
  object BTN2: TRadioButton
    Left = 488
    Top = 46
    Width = 113
    Height = 17
    Align = alCustom
    Caption = 'TODOS'
    TabOrder = 15
  end
  object Edit1: TEdit
    Left = 344
    Top = 19
    Width = 121
    Height = 21
    TabOrder = 16
    Text = 'filtrar por...'
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 65
    Width = 564
    Height = 402
    TabOrder = 17
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Edit2: TEdit
    Left = 0
    Top = 450
    Width = 169
    Height = 21
    TabOrder = 18
    Text = 'digite um nome  * ou para todos'
  end
end
