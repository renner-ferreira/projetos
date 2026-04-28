unit MenuPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TTMenuPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    MANUTENAO1: TMenuItem;
    RELATORIOS1: TMenuItem;
    SAIR1: TMenuItem;
    cliente1: TMenuItem;
    procedure cliente1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  TMenuPrincipal: TTMenuPrincipal;

implementation

uses CLIENTE, CLIENTEC, DMPrincipal;

{$R *.dfm}

procedure TTMenuPrincipal.cliente1Click(Sender: TObject);
begin
TTCliente.CHAMATELA;
end;

end.
