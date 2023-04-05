local ISInventoryPage_prerender = ISInventoryPage.prerender

function ISInventoryPage:prerender()
    if self.onCharacter then
        return ISInventoryPage_prerender(self)
    end

    if self.blinkContainer then
        if not self.blinkAlphaContainer then self.blinkAlphaContainer = 0.7; self.blinkAlphaIncreaseContainer = false; end
        if not self.blinkAlphaIncreaseContainer then
            self.blinkAlphaContainer = self.blinkAlphaContainer - 0.04 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlphaContainer < 0.3 then
                self.blinkAlphaContainer = 0.3;
                self.blinkAlphaIncreaseContainer = true;
            end
        else
            self.blinkAlphaContainer = self.blinkAlphaContainer + 0.04 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlphaContainer > 0.7 then
                self.blinkAlphaContainer = 0.7;
                self.blinkAlphaIncreaseContainer = false;
            end
        end
        for i,v in ipairs(self.backpacks) do
            if (self.blinkContainerType and v.inventory:getType() == self.blinkContainerType) or not self.blinkContainerType then
                if v.inventory == self.inventoryPane.inventory then
                    v:setBackgroundRGBA(1, 0, 0, self.blinkAlphaContainer);
                else
                    v:setBackgroundRGBA(1, 0, 0, self.blinkAlphaContainer * 0.75);
                end
            end
        end
    end

    local titleBarHeight = self:titleBarHeight()
    local height = self:getHeight();
    if self.isCollapsed then
        height = titleBarHeight;
    end

    self:drawRect(0, 0, self:getWidth(), height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);

    if not self.blink then
        self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, titleBarHeight - 2, 1, 1, 1, 1);
    else
        if not self.blinkAlpha then self.blinkAlpha = 1; end
        self:drawRect(2, 1, self:getWidth() - 4, 14, self.blinkAlpha, 1, 1, 1);
--        self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, 14, self.blinkAlpha, 1, 1, 1);

        if not self.blinkAlphaIncrease then
            self.blinkAlpha = self.blinkAlpha - 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlpha < 0 then
                self.blinkAlpha = 0;
                self.blinkAlphaIncrease = true;
            end
        else
            self.blinkAlpha = self.blinkAlpha + 0.1 * (UIManager.getMillisSinceLastRender() / 33.3);
            if self.blinkAlpha > 1 then
                self.blinkAlpha = 1;
                self.blinkAlphaIncrease = false;
            end
        end
    end
    self:drawRectBorder(0, 0, self:getWidth(), titleBarHeight, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if not self.isCollapsed then
        -- Draw border for backpack area...
        self:drawRect(self:getWidth()-self.buttonSize, titleBarHeight, self.buttonSize, height-titleBarHeight-7,  self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    end

--~ 	if not self.title then
--~ 		self.title = getSpecificPlayer(self.player):getDescriptor():getForename().." "..getSpecificPlayer(self.player):getDescriptor():getSurname().."'s Inventory";
--~ 	end

    if self.title and self.onCharacter then
        self:drawText(self.title, self.infoButton:getRight() + 1, 0, 1,1,1,1);
    end

    -- load the current weight of the container
    self.totalWeight = ISInventoryPage.loadWeight(self.inventoryPane.inventory);

    local roundedWeight = round(self.totalWeight, 2)
    local weightText
    if self.capacity then
        if self.inventoryPane.inventory == getSpecificPlayer(self.player):getInventory() then
            weightText = roundedWeight .. " / " .. getSpecificPlayer(self.player):getMaxWeight()
            self:drawTextRight(weightText, self.pinButton:getX(), 0, 1,1,1,1);
        else
            weightText = roundedWeight .. " / " .. self.capacity
            self:drawTextRight(weightText, self.pinButton:getX(), 0, 1,1,1,1);
        end
    else
        weightText = roundedWeight .. ""
        self:drawTextRight(weightText, self.width - 20, 0, 1,1,1,1);
    end

    -- local weightWid = getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99")
    local weightWid = getTextManager():MeasureStringX(UIFont.Small, weightText)
    weightWid = math.max(90, weightWid + 20)
    self.transferAll:setX(self.pinButton:getX() - weightWid - getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_invpage_Transfer_all")));
    if not self.onCharacter or self.width < 370 then
        self.transferAll:setVisible(false)
    elseif not "Tutorial" == getCore():getGameMode() then
        self.transferAll:setVisible(true)
    end

    if self.title and not self.onCharacter then
        local fontHgt = getTextManager():getFontHeight(self.font)
        self:drawTextRight(self.title, self.width - 20 - weightWid, (titleBarHeight - fontHgt) / 2, 1,1,1,1);
    end

    -- self:drawRectBorder(self:getWidth()-32, 15, 32, self:getHeight()-16-6, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:setStencilRect(0,0,self.width+1, height);

    if ISInventoryPage.renderDirty then
        ISInventoryPage.renderDirty = false;
        ISInventoryPage.dirtyUI();
    end
end
