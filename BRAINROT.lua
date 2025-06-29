local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/revision/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = " Hub",
   LoadingTitle = "Carregando...",
   LoadingSubtitle = "Versão 1.0",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "RF_Deltafforce", -- Pasta no workspace
      FileName = "Settings.json"
   },
   Discord = {
      Enabled = true,
      Invite = "discord.gg/", -- Link do seu Discord
      RememberJoins = true
   }
})
