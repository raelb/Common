inherited OptionsSQLIndentationFrame: TOptionsSQLIndentationFrame
  Width = 177
  Height = 338
  object Panel: TBCPanel [0]
    AlignWithMargins = True
    Left = 4
    Top = 0
    Width = 173
    Height = 338
    Margins.Left = 4
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    BevelOuter = bvNone
    Color = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    SkinData.SkinSection = 'CHECKBOX'
    object StickyLabelUseTab: TsStickyLabel
      Left = 0
      Top = 45
      Width = 108
      Height = 13
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      Caption = 'Use tab'
      ParentColor = False
      AttachTo = SliderUseTab
      Gap = 8
    end
    object StickyLabelBlockOnNewLine: TsStickyLabel
      Left = 0
      Top = 153
      Width = 108
      Height = 13
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      Caption = 'Block on new line'
      ParentColor = False
      AttachTo = SliderBlockOnNewLine
      Gap = 8
    end
    object EditIndentLength: TBCEdit
      Left = 0
      Top = 17
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 0
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Indent length'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditTabSize: TBCEdit
      Left = 0
      Top = 81
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 1
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Tab size'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditFunctionBodyIndent: TBCEdit
      Left = 0
      Top = 123
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 2
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Function body indent'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditBlockLeftIndentSize: TBCEdit
      Left = 0
      Top = 191
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 3
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Block left indent size'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditBlockRightIndentSize: TBCEdit
      Left = 0
      Top = 233
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 4
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Block right indent size'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditBlockIndentSize: TBCEdit
      Left = 0
      Top = 275
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 5
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'Block indent size'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object EditSingleStatementIndent: TBCEdit
      Left = 0
      Top = 317
      Width = 64
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      TabOrder = 6
      Text = '2'
      SkinData.SkinSection = 'EDIT'
      BoundLabel.Active = True
      BoundLabel.Caption = 'IF/ELSE single statement indent size'
      BoundLabel.Indent = 4
      BoundLabel.Layout = sclTopLeft
      EnterToTab = False
      OnlyNumbers = True
      NumbersWithDots = False
      NumbersWithSpots = False
      ErrorColor = 14803198
      NumbersAllowMinus = False
      NumbersAllowPlus = False
    end
    object SliderUseTab: TsSlider
      Left = 116
      Top = 41
      Width = 50
      AutoSize = True
      TabOrder = 7
      ImageIndexOff = 0
      ImageIndexOn = 0
      FontOn.Charset = DEFAULT_CHARSET
      FontOn.Color = clWindowText
      FontOn.Height = -11
      FontOn.Name = 'Tahoma'
      FontOn.Style = []
      SliderCaptionOn = 'Yes'
      SliderCaptionOff = 'No'
      KeepThumbAspectRatio = False
    end
    object SliderBlockOnNewLine: TsSlider
      Left = 116
      Top = 149
      Width = 50
      AutoSize = True
      TabOrder = 8
      ImageIndexOff = 0
      ImageIndexOn = 0
      FontOn.Charset = DEFAULT_CHARSET
      FontOn.Color = clWindowText
      FontOn.Height = -11
      FontOn.Name = 'Tahoma'
      FontOn.Style = []
      SliderCaptionOn = 'Yes'
      SliderCaptionOff = 'No'
      KeepThumbAspectRatio = False
    end
  end
end
