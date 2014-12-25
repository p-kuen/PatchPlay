local PANEL = {}
AccessorFunc( PANEL, "m_iIndent", 		"Indent" )

--[[---------------------------------------------------------
	
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetTall( 20 )
	self.NWang = vgui.Create( "DNumberWang", self )
	function self.NWang.OnValueChanged( _, val ) self:OnValueChanged( val ) end

end

function PANEL:SetDark( b )
	if ( self.Label ) then
		self.Label:SetDark( b )
	end
end

function PANEL:SetBright( b )
	if ( self.Label ) then
		self.Label:SetBright( b )
	end
end

--[[---------------------------------------------------------
   Name: SetValue
-----------------------------------------------------------]]
function PANEL:SetValue( val )
	self.NWang:SetValue( val )
end

--[[---------------------------------------------------------
   Name: GetValue
-----------------------------------------------------------]]
function PANEL:GetValue()
	return self.NWang:GetValue()
end

--[[---------------------------------------------------------
   Name: SetMin
-----------------------------------------------------------]]
function PANEL:SetMin(min)
	self.NWang:SetMin(min)
end

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local x = self.m_iIndent or 0

	self.NWang:SizeToContents()
	self.NWang:SetPos( x, 0 )
	
	if ( self.Label ) then
		self.Label:SizeToContents()
		self.Label:SetPos( x + self.NWang:GetWide() + 10, 0 )
	end

end

--[[---------------------------------------------------------
	SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()

	self:PerformLayout( true )
	self:SetWide( self.Label.x + self.Label:GetWide() )
	self:SetTall( self.NWang:GetTall() )
	
end

--[[---------------------------------------------------------
   Name: SetText
-----------------------------------------------------------]]
function PANEL:SetText( text )

	if ( !self.Label ) then
		self.Label = vgui.Create( "DLabel", self )
	end
	
	self.Label:SetText( text )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint()
end

--[[---------------------------------------------------------
   Name: OnValueChanged
-----------------------------------------------------------]]
function PANEL:OnValueChanged( val )

	-- For override

end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetText( "NumberWang" )
		ctrl:SetWide( 200 )
	
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DNumberWangLabel", "Number Wang with Label", PANEL, "DPanel" )