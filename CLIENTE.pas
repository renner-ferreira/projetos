unit CLIENTE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, DBCtrls;

type
  TTCliente = class(TForm)
    t: TPanel;
    FOOTER: TPanel;
    DBNavigator1: TDBNavigator;
    LAB: TLabel;
    LAB1: TLabel;
    MENU: TRadioGroup;
    MAIN: TPanel;
    btnlimpar: TBitBtn;
    btntranferir: TBitBtn;
    btnName: TBitBtn;
    btnExcluir: TBitBtn;
    BitBtn4: TBitBtn;
    btnSair: TBitBtn;
    BTN: TRadioButton;
    BTN1: TRadioButton;
    BTN2: TRadioButton;
    btnConsultar: TBitBtn;
    RG: TDBGrid;
    Edit1: TEdit;
    DBGrid1: TDBGrid;
    Edit2: TEdit;
  private
    procedure btnNameClick(Sender: TObject);
    procedure tClick(Sender: TObject);
    procedure BTN1Click(Sender: TObject);
    procedure BTNClick(Sender: TObject);
    procedure FOOTERClick(Sender: TObject);
    procedure LAB1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    procedure CHAMATELA;
  end;

var
  TCliente: TTCliente;

implementation

{$R *.dfm}

procedure TTCliente.CHAMATELA;
begin
     TCLIENTE := TTCliente.Create(application);
     WITH TCliente do
     begin
     ShowModal;
       end;
     end;


procedure TTCliente.btnNameClick(Sender: TObject);
begin

end;



procedure TTCliente.tClick(Sender: TObject);
begin



end;





procedure TTCliente.FOOTERClick(Sender: TObject);
begin


end;

procedure TTCliente.BTNClick(Sender: TObject);
begin

end;

procedure TTCliente.BTN1Click(Sender: TObject);
begin

end;

procedure TTCliente.RadioGroup1Click(Sender: TObject);
begin

end;

procedure TTCliente.LAB1Click(Sender: TObject);
begin

end;

end.
