object TProdutos: TTProdutos
  Left = 0
  Top = 0
  Caption = 'cadastro de Produtos'
  ClientHeight = 479
  ClientWidth = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 597
    Height = 73
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 884
    object RadioGroup1: TRadioGroup
      Left = 412
      Top = 0
      Width = 185
      Height = 65
      Caption = 'Filtrar por...'
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        'ativos'
        'inativos'
        'todos')
      TabOrder = 0
    end
    object DBNavigator1: TDBNavigator
      Left = 8
      Top = 15
      Width = 216
      Height = 51
      VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 432
    Width = 597
    Height = 47
    Align = alBottom
    TabOrder = 1
  end
  object Panel3: TPanel
    Left = 0
    Top = 384
    Width = 597
    Height = 48
    Align = alBottom
    TabOrder = 2
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 73
    Width = 597
    Height = 311
    Align = alClient
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
end
