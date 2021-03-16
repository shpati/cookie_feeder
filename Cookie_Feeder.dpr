program Cookie_Feeder;

uses
  Forms, System,
  CF in 'CF.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'Cookie Feeder';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
