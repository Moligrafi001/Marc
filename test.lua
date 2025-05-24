local ERVLibrary = loadstring(game:HttpGet("https://ervcommunity.com/library.lua"))()
local Window = ERVLibrary:CreateWindow("ERV Hub", "Build An Island")

-- Global Values
getgenv().CollectResources = false
getgenv().AutoContribute = false
getgenv().AutoHarvest = false
getgenv().AutoSell = false

-- Locals
local eu = game:GetService("Players").LocalPlayer

-- Functions
local function CollectResources()
  while getgenv().CollectResources and task.wait(1) do
    pcall(function()
      for _, resource in pairs(workspace.Plots[eu.Name].Resources:GetChildren()) do
        if resource:GetAttribute("HP") > 0 then
          game:GetService("ReplicatedStorage").Communication.HitResource:FireServer(resource)
        end
      end
    end)
  end
end
local function AutoHarvest()
  while getgenv().AutoHarvest and task.wait(1) do
    pcall(function()
      for _, plant in pairs(workspace.Plots[eu.Name].Plants:GetChildren()) do
        if plant:GetAttribute("Grown") and plant:GetAttribute("Grown") == true then
          game:GetService("ReplicatedStorage").Communication.Harvest:FireServer(plant.Name)
        end
      end
    end)
  end
end
local function AutoContribute()
  while getgenv().AutoContribute and task.wait(1) do
    pcall(function()
      for _, expand in pairs(workspace.Plots[eu.Name].Expand:GetChildren()) do
        for _, resource in pairs(expand.Top.BillboardGui:GetChildren()) do
          pcall(function()
            local atual, maximo = resource.Amount.Text:match("(%d+)/(%d+)")
            if tonumber(atual) < tonumber(maximo) then
              game:GetService("ReplicatedStorage").Communication.ContributeToExpand:FireServer(expand.Name, resource.Name, tonumber(maximo))
            end
          end)
        end
      end
    end)
  end
end
local function AutoSell()
  while getgenv().AutoSell and task.wait(1) do
    game:GetService("ReplicatedStorage").Communication.SellToMerchant:FireServer(true, {})
  end
end

-- Menu
local Menu = Window:CreateTab("97943845400322")
Tab1:CreateSection("Auto Farm")
Tab1:CreateDropdown("Dropdown", { "Option 1", "Option 2" }, function(selected)
    print(selected)
end)
Tab1:CreateToggle("Mine Resources", function(state)
  
end)
Tab1:CreateButton("Button", function()
    print("Button")
end)
Tab1:CreateBox("Box", function(input)
    print(input)
end)