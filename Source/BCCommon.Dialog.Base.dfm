object BCBaseDialog: TBCBaseDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 310
  ClientWidth = 645
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 115
  TextHeight = 13
  object SkinProvider: TsSkinProvider
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 390
    Top = 20
  end
end
