# API Documentation for Dragon Blox Sparking Unleashed

## Table of Contents

- Indexes Module
- CameraManager Module
- GameLoader Module
- RenderService Module

## Indexes Module

**File:** `src/ReplicatedStorage/Indexes/init.lua`

### Description
The Indexes module manages module references and provides indexed references to shared resources across the game framework.

### Functions

- **Indexes:OnLoad(Func)**
  - **Description:** Registers a function that will be called once the Indexes module is loaded.
  - **Parameters:**
    - `Func` (function): The function to be called upon loading.
  - **Example:**
    ```lua
    Indexes:OnLoad(function()
        print("Indexes module loaded.")
    end)
    ```

- **Indexes:Load()**
  - **Description:** Loads and initializes modules, handling any failed modules and setting up direct references.
  - **Returns:**
    - `boolean`: Indicates whether the loading was successful.
    - `number`: The count of failed modules if any.
  - **Example:**
    ```lua
    local success, failedCount = Indexes:Load()
    if success then
        print("Modules loaded successfully.")
    else
        print(failedCount .. " modules failed to load.")
    end
    ```

## CameraManager Module

**File:** `src/ReplicatedStorage/Modules/Systems/CameraManager/init.lua`

### Description
The CameraManager module handles camera setup, transitions, and advanced effects.

### Functions

- **CameraManager:ConnectCam(Cam:Camera)**
  - **Description:** Connects a custom camera object to a camera instance.
  - **Parameters:**
    - `Cam` (Camera): The camera instance to connect to.
  - **Returns:** 
    - The connected CameraObject module.
  - **Example:**
    ```lua
    local CameraManager = require(game.ReplicatedStorage.Modules.Systems.CameraManager)
    local cameraObject = CameraManager:ConnectCam(workspace.CurrentCamera)
    ```

## GameLoader Module

**File:** `src/ReplicatedStorage/Modules/Systems/GameLoader/Client.lua`

### Description
The GameLoader module handles the loading of the game's environment and player scripts.

### Functions

- **GameLoader(Client)**
  - **Description:** Loads the game environment and player scripts.
  - **Parameters:**
    - `Client` (table): The client table passed to the function.
  - **Example:**
    ```lua
    local GameLoader = require(game.ReplicatedStorage.Modules.Systems.GameLoader.Client)
    GameLoader(Client)
    ```

## RenderService Module

**File:** `src/ReplicatedStorage/Modules/GameSystems/RenderService.lua`

### Description
The RenderService module manages various rendering effects and services within the game.

### Functions

- **RenderService:BindHair(Char:Model, HairType, Form)**
  - **Description:** Binds a hair model to a character.
  - **Parameters:**
    - `Char` (Model): The character model.
    - `HairType` (string): The type of hair to bind.
    - `Form` (string): The form of the hair.
  - **Example:**
    ```lua
    RenderService:BindHair(character, "SuperSaiyan", "Base")
    ```

- **RenderService:ShiftFlight(Char:Model, Options)**
  - **Description:** Manages the shift flight effect for a character.
  - **Parameters:**
    - `Char` (Model): The character model.
    - `Options` (table): Options for the shift flight effect.
  - **Example:**
    ```lua
    RenderService:ShiftFlight(character, {Holding = true, StopFlight = false})
    ```

- **RenderService:Transparency(Char:Model, Time)**
  - **Description:** Sets the transparency of a character model over time.
  - **Parameters:**
    - `Char` (Model): The character model.
    - `Time` (number): The duration for the transparency effect.
  - **Example:**
    ```lua
    RenderService:Transparency(character, 1.0)
    ```

- **RenderService:Afterimage(Char:Model, Time)**
  - **Description:** Creates an afterimage effect for a character.
  - **Parameters:**
    - `Char` (Model): The character model.
    - `Time` (number): The duration for the afterimage effect.
  - **Example:**
    ```lua
    RenderService:Afterimage(character, 0.5)
    ```

- **RenderService:Dash(Char:Model)**
  - **Description:** Creates a dash effect for a character.
  - **Parameters:**
    - `Char` (Model): The character model.
  - **Example:**
    ```lua
    RenderService:Dash(character)
    ```

- **RenderService:HitEffect(HRP:Model, Options)**
  - **Description:** Creates a hit effect on a character.
  - **Parameters:**
    - `HRP` (Model): The character model.
    - `Options` (table): Options for the hit effect.
  - **Example:**
    ```lua
    RenderService:HitEffect(character.HumanoidRootPart, {Type = "Punch"})
    ```

- **RenderService:Resize(Part2:Instance, Size:Vector3)**
  - **Description:** Resizes a part instance.
  - **Parameters:**
    - `Part2` (Instance): The part instance to resize.
    - `Size` (Vector3): The new size for the part.
  - **Example:**
    ```lua
    RenderService:Resize(part, Vector3.new(4, 4, 4))
    ```
---