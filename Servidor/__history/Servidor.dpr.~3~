program Servidor;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  FrmTestDefaultServer in 'FrmTestDefaultServer.pas' {Form1},
  ServerMethodsEmpleados in 'ServerMethodsEmpleados.pas',
  WebModuleEmpleados in 'WebModuleEmpleados.pas' {WebModule1: TWebModule},
  UDmEmpleados1 in 'UDmEmpleados1.pas' {DmEmpleados: TDataModule};

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDmEmpleados, DmEmpleados);
  Application.Run;
end.
