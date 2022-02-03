unit Model.Utils;

interface

const
  CConfigFile = 'AddOns.ini';
  CLinksFile = 'addOns.txt';

var
  VFechar: Boolean;

procedure CleanVariables;

implementation

procedure CleanVariables;
begin
   VFechar := False;
end;

end.
