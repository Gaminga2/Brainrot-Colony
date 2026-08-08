--!strict
local MinionTypes = {}

export type MinionClass = "MewingMason" | "OhioLumberjack" | "GyattGuard" | "FanumArcher" | "SkibidiBomber"

MinionTypes.Classes = {
	MewingMason = {
		Name = "Mewing Mason",
		Role = "Builder / Mining",
		WalkSpeed = 16,
		MaxHP = 120,
		BuildSpeedMultiplier = 1.3,
		DefaultSkin = "rbxassetid://0",
		VoiceLines = { "🤫🧏‍♂️ *Mewing intensifies*", "Bye Bye 🤫", "Looksmaxing the fortress!" },
	},
	OhioLumberjack = {
		Name = "Ohio Lumberjack",
		Role = "Woodcutter",
		WalkSpeed = 18,
		MaxHP = 100,
		HarvestSpeedMultiplier = 1.5,
		DefaultSkin = "rbxassetid://0",
		VoiceLines = { "ONLY IN OHIO!!", "TIMBER BRO!", "Screaming at trees!" },
	},
	GyattGuard = {
		Name = "Gyatt Guard",
		Role = "Melee Defender",
		WalkSpeed = 14,
		MaxHP = 250,
		Damage = 20,
		DefaultSkin = "rbxassetid://0",
		VoiceLines = { "Rizz shield UP!", "Unstoppable force!", "Hold the wall!" },
	},
	FanumArcher = {
		Name = "Fanum Archer",
		Role = "Ranged Defender",
		WalkSpeed = 16,
		MaxHP = 90,
		AttackRange = 60,
		Damage = 15,
		DefaultSkin = "rbxassetid://0",
		VoiceLines = { "Fanum Tax incoming!", "Snacking on targets!", "Direct hit!" },
	},
	SkibidiBomber = {
		Name = "Skibidi Bomber",
		Role = "Demolition",
		WalkSpeed = 20,
		MaxHP = 60,
		ExplosionDamage = 200,
		DefaultSkin = "rbxassetid://0",
		VoiceLines = { "SKIBIDI BOOM!!", "Kamikaze time!", "DOP DOP YES YES!" },
	},
}

-- Cosmetic Skins Master Registry (Strictly aesthetic!)
MinionTypes.Skins = {
	Gigachad = {
		Name = "Gigachad Classic",
		ApplicableClasses = { "MewingMason", "GyattGuard" },
		Rarity = "Legendary",
		AuraParticle = "SigmaGlow",
	},
	KaiCenat = {
		Name = "Rizz God Kai",
		ApplicableClasses = { "FanumArcher", "OhioLumberjack" },
		Rarity = "Mythic",
		AuraParticle = "StreamerChat",
	},
	GrimaceShake = {
		Name = "Purple Grimace",
		ApplicableClasses = { "SkibidiBomber" },
		Rarity = "Epic",
		AuraParticle = "PurpleMist",
	},
	GoldenSigma = {
		Name = "Pure Gold Sigma",
		ApplicableClasses = { "MewingMason", "OhioLumberjack", "GyattGuard", "FanumArcher", "SkibidiBomber" },
		Rarity = "Exotic",
		AuraParticle = "GoldSparkles",
	},
}

return MinionTypes
