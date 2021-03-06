/*
	Feathers UI
	Copyright 2020 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.controls.dataRenderers.IDataRenderer;
import feathers.core.FeathersControl;
import feathers.core.IDataSelector;
import feathers.core.IFocusObject;
import feathers.core.IIndexSelector;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.data.IFlatCollection;
import feathers.data.TabBarItemState;
import feathers.events.FeathersEvent;
import feathers.events.FlatCollectionEvent;
import feathers.events.TriggerEvent;
import feathers.layout.ILayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.Measurements;
import feathers.skins.IProgrammaticSkin;
import feathers.themes.steel.components.SteelTabBarStyles;
import feathers.utils.DisplayObjectRecycler;
import haxe.ds.ObjectMap;
import openfl.display.DisplayObject;
import openfl.errors.IllegalOperationError;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
	A line of tabs, where one may be selected at a time.

	The following example sets the data provider, tells the tabs how to
	interpret the data, selects the second tab, and listens for when the
	selection changes:

	```hx
	var tabs = new TabBar();
	tabs.dataProvider = new ArrayCollection([
		{ text: "Latest Posts" },
		{ text: "Profile" },
		{ text: "Settings" }
	]);

	tabBar.itemToText = (item:Dynamic) -> {
		return item.text;
	};

	tabs.selectedIndex = 1;

	tabs.addEventListener(Event.CHANGE, tabs_changeHandler);

	this.addChild(tabs);
	```

	@see [Tutorial: How to use the TabBar component](https://feathersui.com/learn/haxe-openfl/tab-bar/)
	@see `feathers.controls.navigators.TabNavigator`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:access(feathers.data.TabBarItemState)
@:styleContext
class TabBar extends FeathersControl implements IIndexSelector implements IDataSelector<Dynamic> implements IFocusObject {
	private static final INVALIDATION_FLAG_TAB_FACTORY = InvalidationFlag.CUSTOM("tabFactory");

	/**
		The variant used to style the tab child components in a theme.

		@see [Feathers UI User Manual: Themes](https://feathersui.com/learn/haxe-openfl/themes/)

		@since 1.0.0
	**/
	public static final CHILD_VARIANT_TAB = "tabBar_tab";

	private static function defaultUpdateTab(tab:ToggleButton, state:TabBarItemState):Void {
		tab.text = state.text;
	}

	private static function defaultResetTab(tab:ToggleButton, state:TabBarItemState):Void {
		tab.text = null;
	}

	/**
		Creates a new `TabBar` object.

		@since 1.0.0
	**/
	public function new() {
		initializeTabBarTheme();

		super();

		this.addEventListener(KeyboardEvent.KEY_DOWN, tabBar_keyDownHandler);
	}

	private var _dataProvider:IFlatCollection<Dynamic> = null;

	/**
		The collection of data displayed by the tab bar.

		The following example passes in a data provider and tells the tabs how
		to interpret the data:

		```hx
		tabBar.dataProvider = new ArrayCollection([
			{ text: "Latest Posts" },
			{ text: "Profile" },
			{ text: "Settings" }
		]);

		tabBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@default null

		@see `feathers.data.ArrayCollection`

		@since 1.0.0
	**/
	@:flash.property
	public var dataProvider(get, set):IFlatCollection<Dynamic>;

	private function get_dataProvider():IFlatCollection<Dynamic> {
		return this._dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<Dynamic>):IFlatCollection<Dynamic> {
		if (this._dataProvider == value) {
			return this._dataProvider;
		}
		if (this._dataProvider != null) {
			this._dataProvider.removeEventListener(Event.CHANGE, tabBar_dataProvider_changeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.ADD_ITEM, tabBar_dataProvider_addItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ITEM, tabBar_dataProvider_removeItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REPLACE_ITEM, tabBar_dataProvider_replaceItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.REMOVE_ALL, tabBar_dataProvider_removeAllHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.RESET, tabBar_dataProvider_resetHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.SORT_CHANGE, tabBar_dataProvider_sortChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.FILTER_CHANGE, tabBar_dataProvider_filterChangeHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ITEM, tabBar_dataProvider_updateItemHandler);
			this._dataProvider.removeEventListener(FlatCollectionEvent.UPDATE_ALL, tabBar_dataProvider_updateAllHandler);
		}
		this._dataProvider = value;
		if (this._dataProvider != null) {
			this._dataProvider.addEventListener(Event.CHANGE, tabBar_dataProvider_changeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.ADD_ITEM, tabBar_dataProvider_addItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ITEM, tabBar_dataProvider_removeItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REPLACE_ITEM, tabBar_dataProvider_replaceItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.REMOVE_ALL, tabBar_dataProvider_removeAllHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.RESET, tabBar_dataProvider_resetHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.SORT_CHANGE, tabBar_dataProvider_sortChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.FILTER_CHANGE, tabBar_dataProvider_filterChangeHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ITEM, tabBar_dataProvider_updateItemHandler);
			this._dataProvider.addEventListener(FlatCollectionEvent.UPDATE_ALL, tabBar_dataProvider_updateAllHandler);
		}
		if (this._selectedIndex == -1 && this._dataProvider != null && this._dataProvider.length > 0) {
			// use the setter
			this.selectedIndex = 0;
		} else if (this._selectedIndex != -1 && (this._dataProvider == null || this._dataProvider.length == 0)) {
			// use the setter
			this.selectedIndex = -1;
		}
		this.setInvalid(DATA);
		return this._dataProvider;
	}

	private var _selectedIndex:Int = -1;

	/**
		@see `feathers.core.IIndexSelector.selectedIndex`
	**/
	@:flash.property
	public var selectedIndex(get, set):Int;

	private function get_selectedIndex():Int {
		return this._selectedIndex;
	}

	private function set_selectedIndex(value:Int):Int {
		if (this._dataProvider == null) {
			value = -1;
		}
		if (this._selectedIndex == value) {
			return this._selectedIndex;
		}
		this._selectedIndex = value;
		// using variable because if we were to call the selectedItem setter,
		// then this change wouldn't be saved properly
		if (this._selectedIndex == -1) {
			this._selectedItem = null;
		} else {
			this._selectedItem = this._dataProvider.get(this._selectedIndex);
		}
		this.setInvalid(SELECTION);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._selectedIndex;
	}

	/**
		@see `feathers.core.IIndexSelector.maxSelectedIndex`
	**/
	@:flash.property
	public var maxSelectedIndex(get, never):Int;

	private function get_maxSelectedIndex():Int {
		if (this._dataProvider == null) {
			return -1;
		}
		return this._dataProvider.length - 1;
	}

	private var _selectedItem:Dynamic = null;

	/**
		@see `feathers.core.IDataSelector.selectedItem`
	**/
	@:flash.property
	public var selectedItem(get, set):Dynamic;

	private function get_selectedItem():Dynamic {
		return this._selectedItem;
	}

	private function set_selectedItem(value:Dynamic):Dynamic {
		if (this._dataProvider == null) {
			// use the setter
			this.selectedIndex = -1;
			return this._selectedItem;
		}
		// use the setter
		this.selectedIndex = this._dataProvider.indexOf(value);
		return this._selectedItem;
	}

	/**
		Manages tabs used by the tab bar.

		In the following example, the tab bar uses a custom tab renderer class:

		```hx
		tabBar.tabRecycler = DisplayObjectRecycler.withClass(ToggleButton);
		```

		@since 1.0.0
	**/
	public var tabRecycler:DisplayObjectRecycler<Dynamic, TabBarItemState, ToggleButton> = DisplayObjectRecycler.withClass(ToggleButton);

	private var inactiveTabs:Array<ToggleButton> = [];
	private var activeTabs:Array<ToggleButton> = [];
	private var dataToTab = new ObjectMap<Dynamic, ToggleButton>();
	private var tabToData = new ObjectMap<ToggleButton, Dynamic>();
	private var _unrenderedData:Array<Dynamic> = [];

	private var _ignoreSelectionChange = false;

	/**
		Converts an item to text to display within tab bar. By default, the
		`toString()` method is called to convert an item to text. This method
		may be replaced to provide custom text.

		For example, consider the following item:

		```hx
		{ text: "Example Item" }
		```

		If the `TabBar` should display the text "Example Item", a custom
		implementation of `itemToText()` might look like this:

		```hx
		tabBar.itemToText = (item:Dynamic) -> {
			return item.text;
		};
		```

		@since 1.0.0
	**/
	public dynamic function itemToText(data:Dynamic):String {
		return Std.string(data);
	}

	/**
		The layout algorithm used to position and size the tabs.

		By default, if no layout is provided by the time that the tab bar
		initializes, a default layout that displays items horizontally will be
		created.

		The following example tells the tab bar to use a custom layout:

		```hx
		var layout = new HorizontalDistributedLayout();
		layout.maxItemWidth = 300.0;
		tabBar.layout = layout;
		```

		@since 1.0.0
	**/
	@:style
	public var layout:ILayout = null;

	private var _currentBackgroundSkin:DisplayObject = null;
	private var _backgroundSkinMeasurements:Measurements = null;

	/**
		The default background skin to display behind the tabs.

		The following example passes a bitmap for the tab bar to use as a
		background skin:

		```hx
		tabBar.backgroundSkin = new Bitmap(bitmapData);
		```

		@default null

		@see `TabBar.disabledBackgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var backgroundSkin:DisplayObject = null;

	/**
		A background skin to display behind the tabs when the tab bar is
		disabled.

		The following example gives the tab bar a disabled background skin:

		```hx
		tabBar.disabledBackgroundSkin = new Bitmap(bitmapData);
		tabBar.enabled = false;
		```

		@default null

		@see `TabBar.backgroundSkin`

		@since 1.0.0
	**/
	@:style
	public var disabledBackgroundSkin:DisplayObject = null;

	private var _layoutMeasurements = new Measurements();
	private var _layoutResult = new LayoutBoundsResult();
	private var _ignoreChildChanges = false;

	private var _currentItemState = new TabBarItemState();

	private function initializeTabBarTheme():Void {
		SteelTabBarStyles.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(DATA);
		var layoutInvalid = this.isInvalid(LAYOUT);
		var selectionInvalid = this.isInvalid(SELECTION);
		var stateInvalid = this.isInvalid(STATE);
		var stylesInvalid = this.isInvalid(STYLES);
		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);

		if (stylesInvalid || stateInvalid) {
			this.refreshBackgroundSkin();
		}

		if (tabsInvalid || selectionInvalid || stateInvalid || dataInvalid) {
			this.refreshTabs();
		}

		this.refreshViewPortBounds();
		this.handleLayout();
		this.handleLayoutResult();

		this.layoutBackgroundSkin();

		// final invalidation to avoid juggler next frame issues
		this.validateChildren();
	}

	private function refreshViewPortBounds():Void {
		this._layoutMeasurements.save(this);
	}

	private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this.layout.layout(cast this.activeTabs, this._layoutMeasurements, this._layoutResult);
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}

	private function handleLayoutResult():Void {
		var viewPortWidth = this._layoutResult.viewPortWidth;
		var viewPortHeight = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight, viewPortWidth, viewPortHeight);
	}

	private function validateChildren():Void {
		for (tab in this.activeTabs) {
			tab.validateNow();
		}
	}

	private function refreshTabs():Void {
		if (this.tabRecycler.update == null) {
			this.tabRecycler.update = defaultUpdateTab;
			if (this.tabRecycler.reset == null) {
				this.tabRecycler.reset = defaultResetTab;
			}
		}

		var tabsInvalid = this.isInvalid(INVALIDATION_FLAG_TAB_FACTORY);
		this.refreshInactiveTabs(tabsInvalid);
		this.findUnrenderedData();
		this.recoverInactiveTabs();
		this.renderUnrenderedData();
		this.freeInactiveTabs();
		if (this.inactiveTabs.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": inactive item renderers should be empty after updating.");
		}
	}

	private function refreshInactiveTabs(factoryInvalid:Bool):Void {
		var temp = this.inactiveTabs;
		this.inactiveTabs = this.activeTabs;
		this.activeTabs = temp;
		if (this.activeTabs.length > 0) {
			throw new IllegalOperationError(Type.getClassName(Type.getClass(this)) + ": active item renderers should be empty before updating.");
		}
		if (factoryInvalid) {
			this.recoverInactiveTabs();
			this.freeInactiveTabs();
		}
	}

	private function recoverInactiveTabs():Void {
		for (tab in this.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			var item = this.tabToData.get(tab);
			if (item == null) {
				return;
			}
			this.tabToData.remove(tab);
			this.dataToTab.remove(item);
			tab.removeEventListener(TriggerEvent.TRIGGER, tabBar_tab_triggerHandler);
			tab.removeEventListener(Event.CHANGE, tabBar_tab_changeHandler);
			this._currentItemState.owner = this;
			this._currentItemState.data = item;
			this._currentItemState.index = -1;
			this._currentItemState.selected = false;
			this._currentItemState.enabled = true;
			this._currentItemState.text = null;
			var oldIgnoreSelectionChange = this._ignoreSelectionChange;
			this._ignoreSelectionChange = true;
			if (this.tabRecycler.reset != null) {
				this.tabRecycler.reset(tab, this._currentItemState);
			}
			if (Std.is(tab, IDataRenderer)) {
				var dataRenderer = cast(tab, IDataRenderer);
				dataRenderer.data = null;
			}
			tab.selected = this._currentItemState.selected;
			tab.enabled = this._currentItemState.enabled;
			this._ignoreSelectionChange = oldIgnoreSelectionChange;
		}
	}

	private function freeInactiveTabs():Void {
		for (tab in this.inactiveTabs) {
			if (tab == null) {
				continue;
			}
			this.destroyTab(tab);
		}
		this.inactiveTabs.resize(0);
	}

	private function refreshBackgroundSkin():Void {
		var oldSkin = this._currentBackgroundSkin;
		this._currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this._currentBackgroundSkin == oldSkin) {
			return;
		}
		this.removeCurrentBackgroundSkin(oldSkin);
		if (this._currentBackgroundSkin == null) {
			this._backgroundSkinMeasurements = null;
			return;
		}
		if (Std.is(this._currentBackgroundSkin, IUIControl)) {
			cast(this._currentBackgroundSkin, IUIControl).initializeNow();
		}
		if (this._backgroundSkinMeasurements == null) {
			this._backgroundSkinMeasurements = new Measurements(this._currentBackgroundSkin);
		} else {
			this._backgroundSkinMeasurements.save(this._currentBackgroundSkin);
		}
		if (Std.is(this._currentBackgroundSkin, IProgrammaticSkin)) {
			cast(this._currentBackgroundSkin, IProgrammaticSkin).uiContext = this;
		}
		this.addChildAt(this._currentBackgroundSkin, 0);
	}

	private function getCurrentBackgroundSkin():DisplayObject {
		if (!this._enabled && this.disabledBackgroundSkin != null) {
			return this.disabledBackgroundSkin;
		}
		return this.backgroundSkin;
	}

	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void {
		if (skin == null) {
			return;
		}
		if (Std.is(skin, IProgrammaticSkin)) {
			cast(skin, IProgrammaticSkin).uiContext = null;
		}
		// we need to restore these values so that they won't be lost the
		// next time that this skin is used for measurement
		this._backgroundSkinMeasurements.restore(skin);
		if (skin.parent == this) {
			this.removeChild(skin);
		}
	}

	private function layoutBackgroundSkin():Void {
		if (this._currentBackgroundSkin == null) {
			return;
		}
		this._currentBackgroundSkin.x = 0.0;
		this._currentBackgroundSkin.y = 0.0;

		// don't set the width or height explicitly unless necessary because if
		// our explicit dimensions are cleared later, the measurement may not be
		// accurate anymore
		if (this._currentBackgroundSkin.width != this.actualWidth) {
			this._currentBackgroundSkin.width = this.actualWidth;
		}
		if (this._currentBackgroundSkin.height != this.actualHeight) {
			this._currentBackgroundSkin.height = this.actualHeight;
		}
		if (Std.is(this._currentBackgroundSkin, IValidating)) {
			cast(this._currentBackgroundSkin, IValidating).validateNow();
		}
	}

	private function findUnrenderedData():Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (i in 0...this._dataProvider.length) {
			var item = this._dataProvider.get(i);
			var tab = this.dataToTab.get(item);
			if (tab != null) {
				this.refreshTabProperties(tab, item, i);
				this.addChildAt(tab, i + depthOffset);
				var removed = this.inactiveTabs.remove(tab);
				if (!removed) {
					throw new IllegalOperationError(Type.getClassName(Type.getClass(this))
						+ ": data renderer map contains bad data. This may be caused by duplicate items in the data provider, which is not allowed.");
				}
				this.activeTabs.push(tab);
			} else {
				this._unrenderedData.push(item);
			}
		}
	}

	private function renderUnrenderedData():Void {
		var depthOffset = this._currentBackgroundSkin != null ? 1 : 0;
		for (item in this._unrenderedData) {
			var index = this._dataProvider.indexOf(item);
			var tab = this.createTab(item, index);
			this.activeTabs.push(tab);
			this.addChildAt(tab, index + depthOffset);
		}
		this._unrenderedData.resize(0);
	}

	private function createTab(item:Dynamic, index:Int):ToggleButton {
		var tab:ToggleButton = null;
		if (this.inactiveTabs.length == 0) {
			tab = this.tabRecycler.create();
		} else {
			tab = this.inactiveTabs.shift();
		}
		if (tab.variant == null) {
			// if the factory set a variant already, don't use the default
			tab.variant = TabBar.CHILD_VARIANT_TAB;
		}
		this.refreshTabProperties(tab, item, index);
		tab.addEventListener(TriggerEvent.TRIGGER, tabBar_tab_triggerHandler);
		tab.addEventListener(Event.CHANGE, tabBar_tab_changeHandler);
		this.tabToData.set(tab, item);
		this.dataToTab.set(item, tab);
		return tab;
	}

	private function destroyTab(tab:ToggleButton):Void {
		this.removeChild(tab);
		if (this.tabRecycler.destroy != null) {
			this.tabRecycler.destroy(tab);
		}
	}

	private function populateCurrentItemState(item:Dynamic, index:Int):Void {
		this._currentItemState.owner = this;
		this._currentItemState.data = item;
		this._currentItemState.index = index;
		this._currentItemState.selected = item == this._selectedItem;
		this._currentItemState.enabled = this._enabled;
		this._currentItemState.text = itemToText(item);
	}

	private function refreshTabProperties(tab:ToggleButton, item:Dynamic, index:Int):Void {
		this.populateCurrentItemState(item, index);
		var oldIgnoreSelectionChange = this._ignoreSelectionChange;
		this._ignoreSelectionChange = true;
		if (this.tabRecycler.update != null) {
			this.tabRecycler.update(tab, this._currentItemState);
		}
		if (Std.is(tab, IUIControl)) {
			var uiControl = cast(tab, IToggle);
			uiControl.enabled = this._currentItemState.enabled;
		}
		if (Std.is(tab, IDataRenderer)) {
			var dataRenderer = cast(tab, IDataRenderer);
			// if the tab is an IDataRenderer, this cannot be overridden
			dataRenderer.data = this._currentItemState.data;
		}
		tab.selected = this._currentItemState.selected;
		tab.enabled = this._currentItemState.enabled;
		this._ignoreSelectionChange = oldIgnoreSelectionChange;
	}

	private function refreshSelectedIndicesAfterFilterOrSort():Void {
		if (this._selectedIndex == -1) {
			return;
		}
		// the index may have changed, possibily even to -1, if the item was
		// filtered out
		this.selectedIndex = this._dataProvider.indexOf(this._selectedItem); // use the setter
	}

	private function navigateWithKeyboard(event:KeyboardEvent):Void {
		if (this._dataProvider == null || this._dataProvider.length == 0) {
			return;
		}
		var result = this._selectedIndex;
		switch (event.keyCode) {
			case Keyboard.UP:
				result = result - 1;
			case Keyboard.DOWN:
				result = result + 1;
			case Keyboard.LEFT:
				result = result - 1;
			case Keyboard.RIGHT:
				result = result + 1;
			case Keyboard.PAGE_UP:
				result = result - 1;
			case Keyboard.PAGE_DOWN:
				result = result + 1;
			case Keyboard.HOME:
				result = 0;
			case Keyboard.END:
				result = this._dataProvider.length - 1;
			default:
				// not keyboard navigation
				return;
		}
		if (result < 0) {
			result = 0;
		} else if (result >= this._dataProvider.length) {
			result = this._dataProvider.length - 1;
		}
		event.stopPropagation();
		// use the setter
		this.selectedIndex = result;
	}

	private function tabBar_keyDownHandler(event:KeyboardEvent):Void {
		if (!this._enabled) {
			return;
		}
		this.navigateWithKeyboard(event);
	}

	private function tabBar_tab_triggerHandler(event:TriggerEvent):Void {
		var tab = cast(event.currentTarget, ToggleButton);
		var item = this.tabToData.get(tab);
		// trigger before change
		this.dispatchEvent(event);
	}

	private function tabBar_tab_changeHandler(event:Event):Void {
		if (this._ignoreSelectionChange) {
			return;
		}
		var tab = cast(event.currentTarget, ToggleButton);
		if (!tab.selected) {
			// no toggle off!
			tab.selected = true;
			return;
		}
		var item = this.tabToData.get(tab);
		// use the setter
		this.selectedItem = item;
	}

	private function tabBar_dataProvider_changeHandler(event:Event):Void {
		this.setInvalid(DATA);
	}

	private function tabBar_dataProvider_addItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex <= event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_removeItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_replaceItemHandler(event:FlatCollectionEvent):Void {
		if (this._selectedIndex == -1) {
			return;
		}
		if (this._selectedIndex == event.index) {
			FeathersEvent.dispatch(this, Event.CHANGE);
		}
	}

	private function tabBar_dataProvider_removeAllHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
	}

	private function tabBar_dataProvider_resetHandler(event:FlatCollectionEvent):Void {
		// use the setter
		this.selectedIndex = -1;
	}

	private function tabBar_dataProvider_sortChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function tabBar_dataProvider_filterChangeHandler(event:FlatCollectionEvent):Void {
		this.refreshSelectedIndicesAfterFilterOrSort();
	}

	private function updateTabForIndex(index:Int):Void {
		var item = this._dataProvider.get(index);
		var tab = this.dataToTab.get(item);
		if (tab == null) {
			// doesn't exist yet, so we need to do a full invalidation
			this.setInvalid(DATA);
			return;
		}
		this.refreshTabProperties(tab, item, index);
	}

	private function tabBar_dataProvider_updateItemHandler(event:FlatCollectionEvent):Void {
		this.updateTabForIndex(event.index);
	}

	private function tabBar_dataProvider_updateAllHandler(event:FlatCollectionEvent):Void {
		for (i in 0...this._dataProvider.length) {
			this.updateTabForIndex(i);
		}
	}
}
