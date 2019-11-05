/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.core.IPopUpManager;
import openfl.display.Sprite;
import openfl.events.TouchEvent;
import openfl.events.MouseEvent;
import feathers.layout.Measurements;
import feathers.core.IMeasureObject;
import feathers.layout.RelativePosition;
import feathers.events.FeathersEvent;
import feathers.core.IUIControl;
import feathers.core.IValidating;
import feathers.core.InvalidationFlag;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import openfl.geom.Point;
import feathers.layout.HorizontalAlign;
import openfl.geom.Rectangle;
import feathers.core.PopUpManager;
import openfl.errors.ArgumentError;
import openfl.display.DisplayObject;
import feathers.core.FeathersControl;

/**
	@since 1.0.0
**/
@:styleContext
class Callout extends FeathersControl {
	private static final INVALIDATION_FLAG_ORIGIN:String = "origin";

	public static function show(content:DisplayObject, origin:DisplayObject, ?supportedPositions:RelativePositions, modal:Bool = true,
			?customOverlayFactory:() -> DisplayObject):Callout {
		var callout = new Callout();
		callout.content = content;
		return showCallout(callout, origin, supportedPositions, modal, customOverlayFactory);
	}

	private static function showCallout(callout:Callout, origin:DisplayObject, ?supportedPositions:RelativePositions, modal:Bool = true,
			?customOverlayFactory:() -> DisplayObject):Callout {
		callout.supportedPositions = supportedPositions;
		callout.origin = origin;
		var overlayFactory = customOverlayFactory;
		if (overlayFactory == null) {
			overlayFactory = () -> {
				var overlay = new Sprite();
				overlay.graphics.beginFill(0xff00ff, 0.0);
				overlay.graphics.drawRect(0, 0, 1, 1);
				overlay.graphics.endFill();
				return overlay;
			};
		}
		PopUpManager.addPopUp(callout, origin, modal, false, overlayFactory);
		return callout;
	}

	private static function positionBelowOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RelativePosition.TOP);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealXPosition = originBounds.x;
		switch (callout.horizontalAlign) {
			case CENTER:
				{
					idealXPosition += (originBounds.width - callout.width) / 2.0;
				}
			case RIGHT:
				{
					idealXPosition += originBounds.width - callout.width;
				}
			default:
		}
		var minX = stageTopLeft.x + callout.marginLeft;
		var maxX = stageBottomRight.x - callout.width - callout.marginRight;
		var xPosition = idealXPosition;
		if (xPosition < minX) {
			xPosition = minX;
		} else if (xPosition > maxX) {
			xPosition = maxX;
		}
		callout.x = xPosition;
		callout.y = originBounds.y + originBounds.height;
	}

	private static function positionAboveOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RelativePosition.BOTTOM);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealXPosition = originBounds.x;
		switch (callout.horizontalAlign) {
			case CENTER:
				{
					idealXPosition += (originBounds.width - callout.width) / 2.0;
				}
			case RIGHT:
				{
					idealXPosition += originBounds.width - callout.width;
				}
			default:
		}
		var minX = stageTopLeft.x + callout.marginLeft;
		var maxX = stageBottomRight.x - callout.width - callout.marginRight;
		var xPosition = idealXPosition;
		if (xPosition < minX) {
			xPosition = minX;
		} else if (xPosition > maxX) {
			xPosition = maxX;
		}
		callout.x = xPosition;
		callout.y = originBounds.y - callout.height;
	}

	private static function positionLeftOfOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RelativePosition.RIGHT);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealYPosition = originBounds.y;
		switch (callout.verticalAlign) {
			case MIDDLE:
				{
					idealYPosition += (originBounds.height - callout.height) / 2.0;
				}
			case BOTTOM:
				{
					idealYPosition += originBounds.height - callout.height;
				}
			default:
		}
		var minY = stageTopLeft.y + callout.marginTop;
		var maxY = stageBottomRight.y - callout.height - callout.marginBottom;
		var yPosition = idealYPosition;
		if (yPosition < minY) {
			yPosition = minY;
		} else if (yPosition > maxY) {
			yPosition = maxY;
		}
		callout.x = originBounds.x - callout.width;
		callout.y = yPosition;
	}

	private static function positionRightOfOrigin(callout:Callout, originBounds:Rectangle):Void {
		callout.measureWithArrowPosition(RelativePosition.RIGHT);

		var popUpRoot = PopUpManager.forStage(callout.stage).root;

		var stageTopLeft = new Point();
		stageTopLeft = popUpRoot.globalToLocal(stageTopLeft);

		var stageBottomRight = new Point(callout.stage.stageWidth, callout.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var idealYPosition = originBounds.y;
		switch (callout.verticalAlign) {
			case MIDDLE:
				{
					idealYPosition += (originBounds.height - callout.height) / 2.0;
				}
			case BOTTOM:
				{
					idealYPosition += originBounds.height - callout.height;
				}
			default:
		}
		var minY = stageTopLeft.y + callout.marginTop;
		var maxY = stageBottomRight.y - callout.height - callout.marginBottom;
		var yPosition = idealYPosition;
		if (yPosition < minY) {
			yPosition = minY;
		} else if (yPosition > maxY) {
			yPosition = maxY;
		}
		callout.x = originBounds.x + originBounds.width;
		callout.y = yPosition;
	}

	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, callout_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
	}

	private var _contentMeasurements:Measurements;

	public var content(default, set):DisplayObject;

	private function set_content(value:DisplayObject):DisplayObject {
		if (this.content == value) {
			return this.content;
		}
		if (this.content != null) {
			this.content.removeEventListener(Event.RESIZE, callout_content_resizeHandler);
			this._contentMeasurements.restore(this.content);
		}
		this.content = value;
		if (this.content != null) {
			this.content.addEventListener(Event.RESIZE, callout_content_resizeHandler, false, 0, true);
			this.addChild(this.content);
			if (Std.is(this.content, IUIControl)) {
				cast(this.content, IUIControl).initializeNow();
			}
			if (this._contentMeasurements == null) {
				this._contentMeasurements = new Measurements(this.content);
			} else {
				this._contentMeasurements.save(this.content);
			}
		}
		this.setInvalid(InvalidationFlag.DATA);
		this.setInvalid(InvalidationFlag.SIZE);
		return this.content;
	}

	public var origin(default, set):DisplayObject;

	private function set_origin(value:DisplayObject):DisplayObject {
		if (this.origin == value) {
			return this.origin;
		}
		if (value != null && value.stage == null) {
			throw new ArgumentError("origin must be added to the stage.");
		}
		this.origin = value;
		this._lastPopUpOriginBounds = null;
		this.setInvalid(INVALIDATION_FLAG_ORIGIN);
		return this.origin;
	}

	@:style
	public var marginTop:Float = 0.0;

	@:style
	public var marginRight:Float = 0.0;

	@:style
	public var marginBottom:Float = 0.0;

	@:style
	public var marginLeft:Float = 0.0;

	@:style
	public var paddingTop:Float = 0.0;

	@:style
	public var paddingRight:Float = 0.0;

	@:style
	public var paddingBottom:Float = 0.0;

	@:style
	public var paddingLeft:Float = 0.0;

	@:style
	public var horizontalAlign = HorizontalAlign.CENTER;

	@:style
	public var verticalAlign = VerticalAlign.MIDDLE;

	@:style
	public var arrowPosition = RelativePosition.TOP;

	@:style
	public var backgroundSkin:DisplayObject = null;

	public var supportedPositions:Array<RelativePosition>;

	private var _lastPopUpOriginBounds:Rectangle;
	private var _ignoreContentResize:Bool = false;

	/**
		Closes the callout, if opened.

		@since 1.0.0
	**/
	public function close():Void {
		if (this.parent != null) {
			this.parent.removeChild(this);
			FeathersEvent.dispatch(this, Event.CLOSE);
		}
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
		var originInvalid = this.isInvalid(INVALIDATION_FLAG_ORIGIN);
		var sizeInvalid = this.isInvalid(InvalidationFlag.SIZE);
		var stateInvalid = this.isInvalid(InvalidationFlag.STATE);
		var stylesInvalid = this.isInvalid(InvalidationFlag.STYLES);

		if (sizeInvalid) {
			this._lastPopUpOriginBounds = null;
			originInvalid = true;
		}

		if (originInvalid) {
			this.positionRelativeToOrigin();
		}

		if (stateInvalid || dataInvalid) {
			this.refreshEnabled();
		}

		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

		this.layoutChildren();
	}

	private function autoSizeIfNeeded():Bool {
		return this.measureWithArrowPosition(this.arrowPosition);
	}

	private function measureWithArrowPosition(position:RelativePosition):Bool {
		var needsWidth = this.explicitWidth == null;
		var needsHeight = this.explicitHeight == null;
		var needsMinWidth = this.explicitMinWidth == null;
		var needsMinHeight = this.explicitMinHeight == null;
		var needsMaxWidth = this.explicitMaxWidth == null;
		var needsMaxHeight = this.explicitMaxHeight == null;
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight && !needsMaxWidth && !needsMaxHeight) {
			return false;
		}

		if (this.backgroundSkin != null) {
			// this._backgroundSkinMeasurements.resetTargetFluidlyForParent(this.backgroundSkin, this);
		}

		var measureSkin:IMeasureObject = null;
		if (Std.is(this.backgroundSkin, IMeasureObject)) {
			measureSkin = cast(this.backgroundSkin, IMeasureObject);
		}

		if (Std.is(this.backgroundSkin, IValidating)) {
			cast(this.backgroundSkin, IValidating).validateNow();
		}

		if (this.content != null) {
			var oldIgnoreContentReize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this._contentMeasurements.resetTargetFluidlyForParent(this.content, this);
			if (Std.is(this.content, IValidating)) {
				cast(this.content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentReize;
		}

		var newWidth = this.explicitWidth;
		if (needsWidth) {
			var contentWidth = 0.0;
			if (this.content != null) {
				contentWidth = this.content.width;
			}
			newWidth = contentWidth + this.paddingLeft + this.paddingRight;
			if (this.backgroundSkin != null) {
				var backgroundWidth = this.backgroundSkin.width;
				if (newWidth < backgroundWidth) {
					newWidth = backgroundWidth;
				}
			}
		}
		var newHeight = 0.0;
		if (needsHeight) {
			var contentHeight = 0.0;
			if (this.content != null) {
				contentHeight = this.content.height;
			}
			newHeight = contentHeight + this.paddingTop + this.paddingBottom;
			if (this.backgroundSkin != null) {
				var backgroundHeight = this.backgroundSkin.height;
				if (newHeight < backgroundHeight) {
					newHeight = backgroundHeight;
				}
			}
		}
		var newMinWidth = 0.0;
		var newMinHeight = 0.0;
		var newMaxWidth = Math.POSITIVE_INFINITY;
		var newMaxHeight = Math.POSITIVE_INFINITY;

		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight, newMaxWidth, newMaxHeight);
	}

	private function refreshEnabled():Void {
		if (Std.is(this.content, IUIControl)) {
			cast(this.content, IUIControl).enabled = this.enabled;
		}
	}

	private function layoutChildren():Void {
		var xPosition = 0.0;
		var yPosition = 0.0;
		var widthOffset = 0.0;
		var heightOffset = 0.0;
		var backgroundWidth = this.actualWidth - xPosition - widthOffset;
		var backgroundHeight = this.actualHeight - yPosition - heightOffset;
		if (this.backgroundSkin != null) {
			this.backgroundSkin.x = xPosition;
			this.backgroundSkin.y = yPosition;
			this.backgroundSkin.width = backgroundWidth;
			this.backgroundSkin.height = backgroundHeight;
		}

		if (this.content != null) {
			this.content.x = xPosition + this.paddingLeft;
			this.content.y = yPosition + this.paddingTop;
			var oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this.content.width = backgroundWidth - this.paddingLeft - this.paddingRight;
			this.content.height = backgroundHeight - this.paddingTop - this.paddingBottom;
			if (Std.is(this.content, IValidating)) {
				cast(this.content, IValidating).validateNow();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}
	}

	private function positionRelativeToOrigin():Void {
		if (this.origin == null) {
			return;
		}
		var popUpRoot = PopUpManager.forStage(this.stage).root;
		var bounds = this.origin.getBounds(popUpRoot);
		var hasPopUpBounds = this._lastPopUpOriginBounds != null;
		if (hasPopUpBounds && this._lastPopUpOriginBounds.equals(bounds)) {
			return;
		}
		this._lastPopUpOriginBounds = bounds;

		var stageBottomRight = new Point(this.stage.stageWidth, this.stage.stageHeight);
		stageBottomRight = popUpRoot.globalToLocal(stageBottomRight);

		var upSpace = Math.NEGATIVE_INFINITY;
		var downSpace = Math.NEGATIVE_INFINITY;
		var rightSpace = Math.NEGATIVE_INFINITY;
		var leftSpace = Math.NEGATIVE_INFINITY;
		var positions = this.supportedPositions;
		if (positions == null) {
			positions = [
				RelativePosition.BOTTOM,
				RelativePosition.TOP,
				RelativePosition.RIGHT,
				RelativePosition.LEFT,
			];
		}
		for (position in positions) {
			switch (position) {
				case RelativePosition.TOP:
					{
						// arrow is opposite, on bottom side
						this.measureWithArrowPosition(RelativePosition.BOTTOM);
						upSpace = this._lastPopUpOriginBounds.y - this.actualHeight;
						if (upSpace >= this.marginTop) {
							positionAboveOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (upSpace < 0.0) {
							upSpace = 0.0;
						}
					}
				case RelativePosition.RIGHT:
					{
						// arrow is opposite, on left side
						this.measureWithArrowPosition(RelativePosition.LEFT);
						rightSpace = (stageBottomRight.x - this.actualWidth) - (this._lastPopUpOriginBounds.x + this._lastPopUpOriginBounds.width);
						if (rightSpace >= this.marginRight) {
							positionRightOfOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (rightSpace < 0.0) {
							rightSpace = 0.0;
						}
					}
				case RelativePosition.LEFT:
					{
						// arrow is opposite, on right side
						this.measureWithArrowPosition(RelativePosition.RIGHT);
						leftSpace = this._lastPopUpOriginBounds.x - this.actualWidth;
						if (leftSpace >= this.marginLeft) {
							positionLeftOfOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (leftSpace < 0.0) {
							leftSpace = 0.0;
						}
					}
				default: // bottom
					{
						// arrow is opposite, on top side
						this.measureWithArrowPosition(RelativePosition.TOP);
						downSpace = (stageBottomRight.y - this.actualHeight) - (this._lastPopUpOriginBounds.y + this._lastPopUpOriginBounds.height);
						if (downSpace >= this.marginBottom) {
							positionBelowOrigin(this, this._lastPopUpOriginBounds);
							return;
						}
						if (downSpace < 0.0) {
							downSpace = 0.0;
						}
					}
			}
		}
		if (downSpace != Math.NEGATIVE_INFINITY && downSpace >= upSpace && downSpace >= rightSpace && downSpace >= leftSpace) {
			positionBelowOrigin(this, this._lastPopUpOriginBounds);
		} else if (upSpace != Math.NEGATIVE_INFINITY && upSpace >= rightSpace && upSpace >= leftSpace) {
			positionAboveOrigin(this, this._lastPopUpOriginBounds);
		} else if (rightSpace != Math.NEGATIVE_INFINITY && rightSpace >= leftSpace) {
			positionRightOfOrigin(this, this._lastPopUpOriginBounds);
		} else if (leftSpace != Math.NEGATIVE_INFINITY) {
			positionLeftOfOrigin(this, this._lastPopUpOriginBounds);
		} else {
			positionBelowOrigin(this, this._lastPopUpOriginBounds);
		}
	}

	private function callout_addedToStageHandler(event:Event):Void {
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, callout_stage_mouseDownHandler, false, 0, true);
		this.stage.addEventListener(TouchEvent.TOUCH_BEGIN, callout_stage_touchBeginHandler, false, 0, true);
	}

	private function callout_removedFromStageHandler(event:Event):Void {
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, callout_stage_mouseDownHandler);
		this.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, callout_stage_touchBeginHandler);
	}

	private function callout_content_resizeHandler(event:Event):Void {
		if (this._ignoreContentResize) {
			return;
		}
		this.setInvalid(InvalidationFlag.SIZE);
	}

	private function callout_stage_mouseDownHandler(event:MouseEvent):Void {
		if (this.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.close();
	}

	private function callout_stage_touchBeginHandler(event:TouchEvent):Void {
		if (event.isPrimaryTouchPoint) {
			// ignore the primary one because MouseEvent.MOUSE_DOWN will catch it
			return;
		}
		if (this.hitTestPoint(event.stageX, event.stageY)) {
			return;
		}
		this.close();
	}
}

abstract RelativePositions(Array<RelativePosition>) from Array<RelativePosition> to Array<RelativePosition> {
	inline function new(positions:Array<RelativePosition>) {
		this = positions;
	}

	@:from
	public static function fromRelativePosition(position:RelativePosition) {
		return new RelativePositions([position]);
	}
}