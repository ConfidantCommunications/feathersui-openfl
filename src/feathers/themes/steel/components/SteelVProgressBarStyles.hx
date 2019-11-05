/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.themes.steel.components;

import feathers.controls.VProgressBar;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.steel.BaseSteelTheme;

/**
	Initialize "steel" styles for the `VProgressBar` component.

	@since 1.0.0
**/
@:access(feathers.themes.steel.BaseSteelTheme)
class SteelVProgressBarStyles {
	public static function initialize(?theme:BaseSteelTheme):Void {
		if (theme == null) {
			theme = Std.downcast(Theme.fallbackTheme, BaseSteelTheme);
		}
		if (theme == null) {
			return;
		}

		var styleProvider = theme.styleProvider;
		if (styleProvider.getStyleFunction(VProgressBar, null) != null) {
			return;
		}

		styleProvider.setStyleFunction(VProgressBar, null, function(progress:VProgressBar):Void {
			if (progress.fillSkin == null) {
				var fillSkin = new RectangleSkin();
				fillSkin.fill = theme.getActiveThemeFill();
				// fillSkin.disabledFill = theme.getButtonDisabledFill();
				fillSkin.border = theme.getActiveFillBorder();
				fillSkin.cornerRadius = 6.0;
				fillSkin.width = 8.0;
				fillSkin.height = 8.0;
				progress.fillSkin = fillSkin;
			}

			if (progress.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getInsetFill();
				backgroundSkin.border = theme.getInsetBorder();
				backgroundSkin.cornerRadius = 6.0;
				backgroundSkin.width = 8.0;
				backgroundSkin.height = 200.0;
				progress.backgroundSkin = backgroundSkin;
			}
		});
	}
}