unit CLIENTEC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, DB, ADODB;

type
  TTClientec = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ATIVO: TCheckBox;
    Btnsalvar: TBitBtn;
    btncancelar: TBitBtn;
    lbNome: TLabel;
    lbRg: TLabel;
    edNome: TEdit;
    EdRg: TEdit;
    QCliente: TADOQuery;
    dsCliente: TDataSource;
    procedure BtnsalvarClick(Sender: TObject);
    procedure ATIVOClick(Sender: TObject);
    procedure lbNomeClick(Sender: TObject);


  public
     procedure ChamaTela;
  end;

 var
  TClientec: TTClientec;
implementation

uses DMPrincipal;

{$R *.dfm}

procedure TTClientec.ATIVOClick(Sender: TObject);
begin
if ativo.Checked   then
begin
  if ativo.CanFocus then
  ativo.SetFocus;
  exit;
end;

end;

procedure TTClientec.BtnsalvarClick(Sender: TObject);
begin
 if edNome.Text = '' then


begin
 showMessage('informe seu nome !');
 if edNome.CanFocus then
 edNome.SetFocus;
 exit;
end;

 if edRg.Text = '' then
begin
  showMessage('inform um RG!');
  if edRg.CanFocus then
  edRg.SetFocus;
  Exit;

end;


with TDMPrincipal.qAux do
begin
  Close;
  SQL.Clear;
  SQL.Add('INSERT INTO CLIENTE (NOME, RG, ATIVO)');
  SQL.Add('VALUES (');
  SQL.Add(QuotedStr(edNome.Text));
  SQL.Add(',' + QuotedStr(edRg.Text) + ',');
  if ativo.Checked then
    SQL.Add('1')
  else
    SQL.Add('0');
  SQL.Add(')');
  ExecSQL;
end;
end;

 procedure TTClientec.ChamaTela;

begin
TClientec := TTClientec.Create(Application);
  with TClientec do
  begin
    ShowModal;
    FreeAndNil(TClientec);
  end;
end;



end.
