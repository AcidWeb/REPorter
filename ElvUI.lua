local _G = _G
local unpack, pairs = _G.unpack, _G.pairs

if not _G.AddOnSkins then return end
local AS = unpack(_G.AddOnSkins)
if not AS:CheckAddOn("REPorter") then return end

function AS:REPorter()
  AS:StripTextures(_G.REPorterFrameBorder)
  AS:SkinBackdropFrame(_G.REPorterFrameBG, "Transparent")
  _G.REPorterFrameBG:SetOutside(nil, 2, 2)
  _G.REPorterFrameBorderResize:Point("BOTTOMRIGHT", _G.REPorterFrameBorder, "BOTTOMRIGHT", 2, -2)

  AS:SkinFrame(_G.REPorterBar)
  for _, i in pairs({"B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8"}) do
    AS:SkinButton(_G["REPorterBar"..i])
  end
end

AS:RegisterSkin("REPorter", AS.REPorter)
