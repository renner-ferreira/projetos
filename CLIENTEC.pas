unit CLIENTEC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, DBCtrls, Buttons;

type
  TForm1 = class(TForm)
    TCLIENTE: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    RG: TStaticText;
    NOME1: TStaticText;
  private
    { Private declarations }
  public
    { Public declarations }
     procedure CHAMATELA;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.CHAMATELA;
begin
 TCLIENTE := TCliente.Create( application);
     WITH TCliente do
     begin
     ShowModal;
       end;
     end;
      end.



