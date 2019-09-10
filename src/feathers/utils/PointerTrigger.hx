/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.utils;

import feathers.events.FeathersEvent;
import openfl.display.InteractiveObject;
import openfl.events.Event;
import openfl.events.MouseEvent;

/**
	Dispatches `Event.TRIGGERED` (or a custom event type) when the target is
	clicked or tapped.

	@see `feathers.controls.Button`
	@see `feathers.events.FeathersEvent.TRIGGERED`

	@since 1.0.0
**/
class PointerTrigger {
	public function new(target:InteractiveObject = null, ?eventFactory:() -> Event) {
		this.target = target;
		this.eventFactory = eventFactory;
	}

	/**
		The target component that should dispatch the event.

		@since 1.0.0
	**/
	public var target(default, set):InteractiveObject = null;

	private function set_target(value:InteractiveObject):InteractiveObject {
		if (this.target == value) {
			return this.target;
		}
		if (this.target != null) {
			this.target.removeEventListener(MouseEvent.CLICK, target_clickHandler);
		}
		this.target = value;
		if (this.target != null) {
			this.target.addEventListener(MouseEvent.CLICK, target_clickHandler);
		}
		return this.target;
	}

	/**
		The event type to dispatch on trigger.

		@since 1.0.0
	**/
	public var eventFactory(default, set):() -> Event = null;

	private function set_eventFactory(value:() -> Event):() -> Event {
		if (this.eventFactory == value) {
			return this.eventFactory;
		}
		this.eventFactory = value;
		return eventFactory;
	}

	/**
		May be set to `false` to disable the trigger event temporarily until set
		back to `true`.

		@default true

		@since 1.0.0
	**/
	public var enabled(default, default):Bool = true;

	private function target_clickHandler(event:MouseEvent):Void {
		if (!this.enabled) {
			return;
		}
		if (this.eventFactory != null) {
			this.target.dispatchEvent(this.eventFactory());
			return;
		}
		FeathersEvent.dispatch(this.target, FeathersEvent.TRIGGERED);
	}
}