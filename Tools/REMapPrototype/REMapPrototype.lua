function REMapPrototypeInternal_Fill(mapFileName)
	local numDetailTiles = GetNumberOfDetailTiles();
	for i=1, numDetailTiles do
		if mapFileName == "STVDiamondMineBG" then
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName.."1_"..i;
		else
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i;
		end
		_G["REMapPrototypeInternal_"..i]:SetTexture(texName);
	end

	REMapPrototypeExternal:SetPoint("CENTER");
end
