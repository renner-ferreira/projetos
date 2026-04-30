program ProjEstagiario;

uses
  Forms,
  DMPrincipal in 'DMPrincipal.pas' {TDMPrincipal: TDataModule},
  CLIENTE in 'CLIENTE.pas' {TCliente},
  CLIENTEC in 'CLIENTEC.pas' {TCLIENTEC},
  MenuPrincipal in 'MenuPrincipal.pas' {TMenuPrincipal};


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTDMPrincipal, TDMPrincipal);
  Application.CreateForm(TTMenuPrincipal, TMenuPrincipal);
  Application.CreateForm(TTMenuPrincipal, TMenuPrincipal);
  Application.Run;
end.
