unit CLIENTE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, DBCtrls,
  CLIENTEC;

type
  TTCliente = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    dbGridCliente: TDBGrid;
    edPesquisa: TEdit;
    btnLimpar: TBitBtn;
    btnFechar: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    DBNavigator1: TDBNavigator;
    RadioGroup1: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    procedure BTNINSERIRClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnNameClick(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);

    private

    public
      procedure ChamaTela;
  end;

var
  TCliente: TTCliente;

implementation

{$R *.dfm}

procedure TTCliente.BTNINSERIRClick(Sender: TObject);
begin
  TClienteC.ChamaTela;
end;

procedure TTCliente.BitBtn5Click(Sender: TObject);
begin
    TClienteC.ChamaTela;
end;

procedure TTCliente.BitBtn6Click(Sender: TObject);
begin
    TClienteC.ChamaTela;
end;

procedure TTCliente.btnConsultarClick(Sender: TObject);
begin
  TClienteC.ChamaTela;
end;

procedure TTCliente.btnNameClick(Sender: TObject);
begin
  TClienteC.ChamaTela;
end;

procedure TTCliente.ChamaTela;
begin
  TCliente := TTCliente.Create(Application);
  with TCliente do
  begin
    ShowModal;
    FreeAndNil(TCliente);
  end;
end;

end.
