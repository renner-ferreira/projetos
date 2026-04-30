object TMenuPrincipal: TTMenuPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'TMenuPrincipal'
  ClientHeight = 289
  ClientWidth = 388
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu1: TMainMenu
    Left = 48
    Top = 24
    object MANUTENAO1: TMenuItem
      Caption = 'MANUTEN'#199'AO'
      object cliente1: TMenuItem
        Caption = 'Cliente'
        OnClick = cliente1Click
      end
    end
    object RELATORIOS1: TMenuItem
      Caption = 'RELATORIOS'
    end
    object SAIR1: TMenuItem
      Caption = 'SAIR'
    end
  end
end
