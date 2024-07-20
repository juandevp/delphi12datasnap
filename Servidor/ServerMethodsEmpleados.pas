unit ServerMethodsEmpleados;

interface

uses System.SysUtils, System.Classes, Datasnap.DSServer, Datasnap.DSAuth,
  UDmEmpleados, System.JSON, REST.JSON;

type
{$METHODINFO ON}
  TServerMethodsEmpleados = class(TComponent)
  private

    { Private declarations }
  public
    { Public declarations }
    function updateEmpleado(AJsonObject: TJSONObject): string;
    function acceptEmpleado(AJsonObject: TJSONObject): string;
    function getdependencias: TJSONValue;
    function getEmpleados: TJSONArray;
    function cancelEmpleados(AId: string): string;
    function updateDependencia(AJsonObject: TJSONObject): string;

    { Metodos para declarar declarations }
  end;
{$METHODINFO OFF}

implementation

uses UEmpleado;

function TServerMethodsEmpleados.updateDependencia
  (AJsonObject: TJSONObject): string;
var
  dependencia: TDependencia;
begin
  try
    dependencia := TJson.JsonToObject<TDependencia>(AJsonObject.ToString);
    DmEmpleados.CrearDependencia(dependencia);
    Result := Format('La dependencia: %s registrada correctamente.',
      [dependencia.dep_nombredependencia]);
  except
    on E: Exception do
    begin
      Result := E.Message;
    end;
  end;
end;

function TServerMethodsEmpleados.cancelEmpleados(AId: string): string;
var
  IdEmpleado, RegModificados: Integer;

begin
  TryStrToInt(AId, IdEmpleado);
  RegModificados := DmEmpleados.EliminarEmpleado(IdEmpleado);
  if RegModificados > 0 then
  begin
    Result := 'Usuario eliminado correctamente: ' + AId;
  end
  else
  begin
    Result := 'No se pudo eliminar el registro: ' + AId;
  end;

end;

function TServerMethodsEmpleados.getEmpleados: TJSONArray;
begin
  Result := DmEmpleados.ObtenerListaEmpleados;
end;

function TServerMethodsEmpleados.acceptEmpleado(AJsonObject
  : TJSONObject): string;
var
  Empleado: TEmpleado;
begin
  try
    Empleado := TJson.JsonToObject<TEmpleado>(AJsonObject.ToString);
    DmEmpleados.ActualizarInfoEmpleado(Empleado);
    Result := Format('Empleado identificado con: %s actualizado correctamente.',
      [Empleado.fun_cidentificacion]);
  except
    on E: Exception do
    begin
      Result := E.Message;
    end;
  end;
end;

function TServerMethodsEmpleados.getdependencias: TJSONValue;
begin
  Result := TJson.ObjectToJsonObject(DmEmpleados.ObtenerDependencias)
    .GetValue('listHelper');
end;

function TServerMethodsEmpleados.updateEmpleado(AJsonObject
  : TJSONObject): string;
var
  JsonEmpleados: TJSONObject;
  Empleado: TEmpleado;
begin

  try
    Empleado := TJson.JsonToObject<TEmpleado>(AJsonObject.ToString);
    DmEmpleados.GuardarEmpleados(Empleado);
    Result := Format('Empleado identificado con: %s registrado correctamente.',
      [Empleado.fun_cidentificacion]);
  except
    on E: Exception do
    begin
      Result := E.Message;
    end;
  end;
end;

end.
