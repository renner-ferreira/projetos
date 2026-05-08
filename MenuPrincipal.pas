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
    FORNECEDOR1: TMenuItem;
    procedure cliente1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FORNECEDOR1Click(Sender: TObject);
    procedure SAIR1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     procedure ChamaTela;
  end;

var
  TMenuPrincipal: TTMenuPrincipal;

implementation

uses CLIENTE, CLIENTEC, FORNECEDOR;

{$R *.dfm}

procedure TTMenuPrincipal.ChamaTela;
begin

end;

procedure TTMenuPrincipal.cliente1Click(Sender: TObject);
begin
  TCliente.ChamaTela;
end;

procedure TTMenuPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  begin
    if Key = VK_ESCAPE then
    begin
      Close;
    end;
  end;
end;

procedure TTMenuPrincipal.FORNECEDOR1Click(Sender: TObject);
begin
  // TFornecedores é a variável global que o Delphi criou no seu arquivo
  // TTFornecedores é o nome da classe (o molde da tela)

  TFornecedores := TTFornecedores.Create(Self);
  try
    TFornecedores.ShowModal;
  finally
    FreeAndNil(TFornecedores);
  end;
end;
procedure TTMenuPrincipal.SAIR1Click(Sender: TObject);
begin
 Close;
end;

end.
