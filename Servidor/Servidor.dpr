program Servidor;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  FrmTestDefaultServer in 'FrmTestDefaultServer.pas' {frmTesteadorServidor},
  ServerMethodsEmpleados in 'ServerMethodsEmpleados.pas',
  WebModuleEmpleados in 'WebModuleEmpleados.pas' {WebModule1: TWebModule},
  UDmEmpleados in 'UDmEmpleados.pas' {DmEmpleados: TDataModule},
  UEmpleado in 'UEmpleado.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfrmTesteadorServidor, frmTesteadorServidor);
  Application.CreateForm(TDmEmpleados, DmEmpleados);
  Application.Run;
end.
