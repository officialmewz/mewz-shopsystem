let selectedCategory = null
let selectedItem = null
let playerMoney = 0

let items = {}
let categories = []
let basket = []

function isInFiveM() {
  return typeof GetParentResourceName === 'function'
}

function GetParentResourceNameSafe() {
  if (typeof GetParentResourceName === 'function') {
    return GetParentResourceName()
  }
  return 'fh_shop'
}

function resetToDefaultState() {
  selectedCategory = categories[0] || null
  selectedItem = null
  basket = []
  isProcessingPayment = false

  const mainTabs = document.getElementById("main-tabs")
  if (mainTabs) mainTabs.style.display = "flex"
  
  if (selectedCategory) {
    const buttons = document.querySelectorAll("#main-tabs .tab-btn")
    buttons.forEach(btn => {
      if (btn.dataset.category === selectedCategory) {
        btn.classList.add('active')
      } else {
        btn.classList.remove('active')
      }
    })
  }
  
  updateBasketSidebar()
  updateItemGrid()
  updateBottomButtons()
}

function getCategoriesFromConfig() {
  const categoryOrder = [
    'MAD',
    'DRIKKE',
    'ITEMS',
    'ELEKTRONIK',
    'HÅNDVÅBEN'
  ];
  
  const validCategories = categoryOrder.filter(cat => {
    const isValid = items[cat] && Array.isArray(items[cat]);
    return isValid;
  });
  
  return validCategories;
}

function initializeUI(data) {
  document.body.style.display = "block"
  document.body.style.overflow = "hidden"
  playerMoney = data.money || 0
  items = data.items || {}
  
  isProcessingPayment = false
  
  const locationNameEl = document.getElementById('location-name')
  if (locationNameEl) {
    if (data.playerFullName) {
      locationNameEl.textContent = 'Velkommen, ' + data.playerFullName
    } else if (data.locationName) {
      locationNameEl.textContent = 'Velkommen, ' + data.locationName
    }
  }
  
  categories = getCategoriesFromConfig()
  
  if (categories.length > 0) {
    selectedCategory = categories[0]
    
    updateCategoriesUI()
    
    showItems()
    updateItemGrid()
    updateUI()
  }
}

window.addEventListener("message", (event) => {
  try {
    if (!event || !event.data) {
      return;
    }

    const data = event.data;
    const action = data?.action;
    
    if (!action) {
      return;
    }
    
    switch (action) {
      case "show":
      case "openShop":
        resetToDefaultState();
        
        document.body.style.display = "block";
        document.body.style.overflow = "hidden";
        
        setTimeout(() => {
          initializeUI(data);
        }, 50);
        break;        
      case "hide":
      case "closeShop":
        document.body.style.display = "none";
        document.body.style.overflow = "hidden";
        
        resetToDefaultState();
        
        isProcessingPayment = false;
        
        if (action === "closeShop" && isInFiveM()) {
          const parentResourceName = GetParentResourceNameSafe();
          fetch(`https://${parentResourceName}/closeShop`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({}),
          }).catch(() => {});
        }
        break;
      case "purchaseResponse":
        isProcessingPayment = false
        if (data.success) {
          basket = []
          updateBasketSidebar()
          updateItemGrid()
          updateBottomButtons()
          document.body.style.display = "none"
          document.body.style.overflow = "hidden"
          resetToDefaultState()
        } else {
          updateBasketSidebar()
          updateBottomButtons()
        }
        break;
    }
  } catch (error) {
  }
});

function updateCategoriesUI() {
  const mainTabs = document.getElementById("main-tabs")
  if (!mainTabs) return
  
  mainTabs.innerHTML = ''
  
  categories.forEach(category => {
    if (!category) return
    
    const button = document.createElement("button")
    button.className = `tab-btn ${category === selectedCategory ? 'active' : ''}`
    button.dataset.category = category
    button.textContent = category
    button.addEventListener("click", () => {
      selectedCategory = category
      const mainTabsEl = document.getElementById("main-tabs")
      
      if (mainTabsEl) mainTabsEl.style.display = "flex"
      
      document.querySelectorAll("#main-tabs .tab-btn").forEach(btn => {
        btn.classList.remove('active')
      })
      button.classList.add('active')
      
      updateUI()
    })
    
    mainTabs.appendChild(button)
  })
}

function setupTabs() {
}

function closeShop() {
  if (isInFiveM()) {
    document.body.style.display = "none"
  }
  resetToDefaultState()
  
  if (isInFiveM()) {
    const parentResourceName = GetParentResourceNameSafe()
    fetch(`https://${parentResourceName}/closeShop`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({}),
    }).catch(() => {})
  }
}

function addItemToBasket(itemId) {
  const item = items[selectedCategory]?.find((i) => i.id === itemId)
  if (!item) return

  const canAfford = canAffordItem(item)
  if (!canAfford) return

  const existingItem = basket.find((b) => b.id === itemId)
  if (existingItem) {
    existingItem.quantity += 1
  } else {
    basket.push({
      ...item,
      quantity: 1,
    })
  }

  updateBasketSidebar()
  updateItemGrid()
  updateBottomButtons()
}

function updateItemQuantity(itemId, newQuantity) {
  const item = items[selectedCategory]?.find((i) => i.id === itemId)
  if (!item) return

  if (newQuantity <= 0) {
    removeFromBasket(itemId)
  } else {
    const basketItem = basket.find((b) => b.id === itemId)
    if (basketItem) {
      basketItem.quantity = Math.max(1, Number.parseInt(newQuantity) || 1)
      updateBasketSidebar()
      updateItemGrid()
    }
  }
}

function removeFromBasket(itemId) {
  basket = basket.filter((item) => item.id !== itemId)
  updateBasketSidebar()
  updateItemGrid()
  updateBottomButtons()
}

function updateQuantity(itemId, newQuantity) {
  const item = basket.find((item) => item.id === itemId)
  if (item) {
    if (newQuantity <= 0) {
      removeFromBasket(itemId)
    } else {
      item.quantity = Math.max(1, Number.parseInt(newQuantity) || 1)
      updateBasketSidebar()
      updateBottomButtons()
    }
  }
}

let isProcessingPayment = false

function purchaseAll() {
  if (basket.length === 0) return
  if (isProcessingPayment) return

  const basketData = basket.map((item) => ({
    itemId: item.id,
    quantity: item.quantity,
  }))

  if (isInFiveM()) {
    isProcessingPayment = true
    updateBasketSidebar()
    updateBottomButtons()
    
    const parentResourceName = GetParentResourceNameSafe()
    fetch(`https://${parentResourceName}/purchaseBasket`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        basket: basketData,
      }),
    }).then((response) => {
      if (!response.ok) {
        isProcessingPayment = false
        updateBasketSidebar()
        updateBottomButtons()
      }
    }).catch((error) => {
      isProcessingPayment = false
      updateBasketSidebar()
      updateBottomButtons()
    })
  } else {
    alert(`Mock purchase: ${basket.length} items for ${getBasketTotal().toLocaleString()} DKK`)
    basket = []
    updateBasketSidebar()
    updateItemGrid()
    updateBottomButtons()
  }
}


function getBasketTotal() {
  return basket.reduce((total, item) => total + item.price * item.quantity, 0)
}
function getBasketItemCount() {
  return basket.reduce((count, item) => count + item.quantity, 0)
}

function isItemInBasket(itemId) {
  return basket.some((item) => item.id === itemId)
}
function canAffordItem(item) {
  return playerMoney >= item.price
}
function canPurchaseItem(item) {
  return canAffordItem(item)
}

function updateUI() {
  updateMoneyDisplay()

  if (!selectedCategory && categories.length > 0) {
    selectedCategory = categories[0]
  }

  if (selectedCategory) {
    showItems()
    updateItemGrid()
  }

  updateBasketSidebar()
  updateBottomButtons()
}

function updateMoneyDisplay() {
  const moneyElement = document.getElementById("player-money")
  if (moneyElement) {
    moneyElement.textContent = `Saldo: ${playerMoney.toLocaleString()} DKK`
  }
}

function showItems() {
  const itemsContainer = document.getElementById("items-container")
  const itemDetails = document.getElementById("item-details")
  const contentGrid = document.getElementById("content-grid")

  if (itemsContainer) itemsContainer.style.display = "grid"
  if (itemDetails) itemDetails.style.display = "flex"
  if (contentGrid) contentGrid.classList.remove("basket-mode")

  updateItemGrid()
}

function updateBasketSidebar() {
  const basketItemsSidebar = document.getElementById("basket-items-sidebar")
  const basketItemCount = document.getElementById("basket-item-count")
  const basketSubtotal = document.getElementById("basket-subtotal")
  const basketTotal = document.getElementById("basket-total")

  if (!basketItemsSidebar) return

  const itemCount = getBasketItemCount()
  const total = getBasketTotal()

  if (basketItemCount) {
    basketItemCount.textContent = `${itemCount} items`
  }

  if (basketSubtotal) {
    basketSubtotal.textContent = `${total.toFixed(2)} DKK`
  }

  if (basketTotal) {
    basketTotal.textContent = `${total.toFixed(2)} DKK`
  }

  basketItemsSidebar.innerHTML = ""

  if (isProcessingPayment) {
    basketItemsSidebar.innerHTML = `
      <div class="basket-processing">
        <div class="basket-loader"></div>
        <div class="basket-processing-text">Afventer transaction...</div>
      </div>
    `
    return
  }

  if (basket.length === 0) {
    basketItemsSidebar.innerHTML = '<div class="basket-empty">Kurven er tom</div>'
    return
  }

  const getItemImage = (itemName) => {
    if (!isInFiveM()) {
      return `https://via.placeholder.com/100x100?text=${encodeURIComponent(itemName)}`
    }
    return `nui://ox_inventory/web/images/${itemName}.png`
  }

  basket.forEach((item) => {
    const basketItem = document.createElement("div")
    basketItem.className = "basket-item-sidebar"

    const imageSrc = item.item ? getItemImage(item.item) : getItemImage('placeholder')
    const fallbackSrc = getItemImage('placeholder')

    basketItem.innerHTML = `
      <div class="basket-item-image-small">
        <img 
          src="${imageSrc}" 
          alt="${item.name}"
          onerror="this.onerror=null; this.src='${fallbackSrc}'"
        />
      </div>
      <div class="basket-item-info-small">
        <div class="basket-item-name-small">${item.name}</div>
        <div class="basket-item-price-small">${(item.price * item.quantity).toLocaleString()} DKK</div>
      </div>
      <div class="basket-item-controls-small">
        <div class="quantity-controls-small">
          <button class="quantity-btn-small" onclick="updateQuantity(${item.id}, ${item.quantity - 1})">−</button>
          <input type="number" class="quantity-input-small" value="${item.quantity}" min="1" onchange="updateQuantity(${item.id}, parseInt(this.value) || 1)" onblur="this.value = Math.max(1, parseInt(this.value) || 1); updateQuantity(${item.id}, parseInt(this.value))">
          <button class="quantity-btn-small" onclick="updateQuantity(${item.id}, ${item.quantity + 1})">+</button>
        </div>
      </div>
    `

    basketItemsSidebar.appendChild(basketItem)
  })
}

function updateItemGrid() {
  const grid = document.getElementById("items-container")
  if (!grid) {
    return
  }

  grid.innerHTML = ""

  const categoryItems = items[selectedCategory] || []

  categoryItems.forEach((item) => {
    const itemElement = document.createElement("div")
    itemElement.className = "weapon-item"
    const canPurchase = canPurchaseItem(item)
    const canAfford = canAffordItem(item)
    
    const basketItem = basket.find((b) => b.id === item.id)
    const currentQuantity = basketItem ? basketItem.quantity : 0
    
    const getItemImage = (itemName) => {
      if (!isInFiveM()) {
        return `https://via.placeholder.com/100x100?text=${encodeURIComponent(itemName)}`
      }
      return `nui://ox_inventory/web/images/${itemName}.png`
    }

    const imageSrc = item.item ? getItemImage(item.item) : getItemImage('placeholder')
    const fallbackSrc = getItemImage('placeholder')

    itemElement.innerHTML = `
      <div class="weapon-image-container">
        <img 
          src="${imageSrc}" 
          alt="${item.name}"
          class="weapon-image"
          onerror="this.onerror=null; this.src='${fallbackSrc}'"
        />
      </div>
      <div class="weapon-info">
        <div class="weapon-name">${item.label || item.name}</div>
        <div class="weapon-price">${item.price.toLocaleString()} DKK</div>
      </div>
      <div class="weapon-controls">
        <button class="item-add-btn ${currentQuantity > 0 ? 'item-remove-btn' : ''}" onclick="event.stopPropagation(); ${currentQuantity > 0 ? `removeFromBasket(${item.id})` : `addItemToBasket(${item.id})`}" ${!canAfford && currentQuantity === 0 ? 'disabled' : ''}>
          ${currentQuantity > 0 ? 'FJERN VAREN' : 'TILFØJ TIL KURV'}
        </button>
      </div>
    `
    
    if (!canPurchase) {
      itemElement.classList.add("disabled")
        
      let tooltipText = '';
        
      if (!canAfford) {
        tooltipText = `Mangler ${(item.price - playerMoney).toLocaleString()} DKK`;
      } else {
        tooltipText = 'Utilgængelig';
      }
        
      const lockOverlay = document.createElement("div")
      lockOverlay.className = "weapon-lock-overlay"
        
      if (!canAfford) {
        lockOverlay.innerHTML = `<div class="weapon-lock-text">${item.price.toLocaleString()} DKK</div>`
      }
        
      const tooltip = document.createElement('div');
      tooltip.className = 'weapon-tooltip';
      tooltip.textContent = tooltipText;
        
      itemElement.addEventListener('mouseenter', () => {
        tooltip.style.opacity = '1';
        tooltip.style.visibility = 'visible';
      });
        
      itemElement.addEventListener('mouseleave', () => {
        tooltip.style.opacity = '0';
        tooltip.style.visibility = 'hidden';
      });
        
      itemElement.appendChild(tooltip);
      itemElement.appendChild(lockOverlay);
    }

    grid.appendChild(itemElement)
  })

  setupButtonListeners()
}


function setupButtonListeners() {
  const purchaseAllBtn = document.getElementById("purchase-all-btn")

  if (purchaseAllBtn) {
    purchaseAllBtn.removeEventListener("click", purchaseAll)
    purchaseAllBtn.addEventListener("click", purchaseAll)
  }
}


function updateItemDetails() {
}

function updateBottomButtons() {
  const purchaseAllBtn = document.getElementById("purchase-all-btn")

  if (purchaseAllBtn) {
    const basketTotal = getBasketTotal()
    const canAffordBasket = playerMoney >= basketTotal

    purchaseAllBtn.disabled = basket.length === 0 || !canAffordBasket || isProcessingPayment
    
    if (isProcessingPayment) {
      purchaseAllBtn.textContent = 'Behandler...'
    } else {
      purchaseAllBtn.textContent = 'Betal'
    }
  }
}


let escHandled = false
document.addEventListener('keydown', function(event) {
  if ((event.key === 'Escape' || event.keyCode === 27) && !escHandled) {
    if (document.body.style.display !== 'none') {
      escHandled = true
      if (isInFiveM()) {
        const parentResourceName = GetParentResourceNameSafe()
        fetch(`https://${parentResourceName}/closeShop`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
          },
          body: JSON.stringify({}),
        }).catch(() => {})
      }
      setTimeout(() => {
        escHandled = false
      }, 500)
    }
  }
})

document.addEventListener("DOMContentLoaded", () => {
  setupButtonListeners()
})
