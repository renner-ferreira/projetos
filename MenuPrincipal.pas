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
     procedure ChamaTela;
  end;

var
  TMenuPrincipal: TTMenuPrincipal;

implementation

uses CLIENTE, CLIENTEC;

{$R *.dfm}

procedure TTMenuPrincipal.ChamaTela;
begin

end;

procedure TTMenuPrincipal.cliente1Click(Sender: TObject);
begin
  TCliente.ChamaTela;
end;

end.
