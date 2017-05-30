package com.flashgen.ui.controls 
{
	import flash.display.Sprite;
	import flash.events.TouchEvent;
	import flash.system.Capabilities;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class ThumbStick extends Sprite 
	{
		private var _thumb		:Sprite;
		private var _surround	:Sprite;
		private var _boundary	:Sprite;
		
		private var _degrees	:Number;
		private var _radius		:Number = 25;	
		
		private var _primaryKeyCode		:int;
		private var _secondaryKeyCode	:int;
		
		private var _previousPrimaryKeyCode		:int;
		private var _previousSecondaryKeyCode	:int = 0;
		
		public function ThumbStick() 
		{
			_thumb = thumb;
			_surround = surround;
			_boundary = boundary;
			_boundary.width = 200;
			_boundary.height = 200;
			_boundary.alpha = 0;
			
			if(Capabilities.cpuArchitecture == "ARM")
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				_thumb.addEventListener(TouchEvent.TOUCH_BEGIN, onThumbDown);
				_thumb.addEventListener(TouchEvent.TOUCH_END, onThumbUp);
				_surround.addEventListener(TouchEvent.TOUCH_END, onThumbUp);
				_boundary.addEventListener(TouchEvent.TOUCH_END, onThumbUp);
			}
			else
			{
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onTestThumbDown);	
				_thumb.addEventListener(MouseEvent.MOUSE_UP, onTestThumbUp);	
				_surround.addEventListener(MouseEvent.MOUSE_UP, onTestThumbUp);
				_boundary.addEventListener(MouseEvent.MOUSE_UP, onTestThumbUp);
			}
		}
		
		protected function initDrag():void
		{
			_thumb.startDrag();
			addEventListener(Event.ENTER_FRAME, onThumbDrag);
		}
		
		protected function resetThumb():void
		{
			removeEventListener(Event.ENTER_FRAME, onThumbDrag);
			
			killAllEvents();
			
			_thumb.stopDrag();	
			_thumb.x = 0;
			_thumb.y = 0;
		}
		
		protected function onThumbDrag(e:Event):void
		{
			// Store the current x/y of the knob
			var _currentX		:Number = _thumb.x;
			var _currentY		:Number = _thumb.y;
			
			// Store the registration point of the surrounding 'joystick holder'
			var _registrationX	:Number = _surround.x;
			var _registrationY	:Number = _surround.y;
			
			// Subtract the two from each other to get the actual x/y
			var _actualX	:Number = _currentX - _registrationX;
			var _actualY	:Number =  _currentY - _registrationY;
			
			// Calculate the degrees for use when creating the zones.
			_degrees = Math.round(Math.atan2(_actualY, _actualX) * 180/Math.PI);
			
			// Calculate the radian value of the knobs current position
			var _angle 		:Number = _degrees * (Math.PI / 180);
			
			// As we want to lock the orbit of the knob we need to calculate x/y at the maximum distance
			var _maxX		:Number = Math.round((_radius * Math.cos(_angle)) + _registrationX);
			var _maxY		:Number = Math.round((_radius * Math.sin(_angle)) + _registrationY);
			
			// Check to make sure that the value is positive or negative
			if(_currentX > 0 && _currentX > _maxX || _currentX < 0 && _currentX < _maxX)
				_thumb.x = _maxX;
			
			if(_currentY > 0 && _currentY > _maxY || _currentY < 0 && _currentY < _maxY)
				_thumb.y = _maxY;
		
			dispatchKeyCombo();
		}
		
		protected function dispatchKeyCombo():void
		{
			_secondaryKeyCode = 0;
			
			// Thumb stick position - Right
			if(_degrees >= -22 && _degrees <= 22)
			{
				_primaryKeyCode = Keyboard.RIGHT;
			}
			// Thumb stick position - Down
			else if (_degrees >= 68 && _degrees <= 112)
			{
				_primaryKeyCode = Keyboard.DOWN;
			}
			// Thumb stick position - Left
			else if((_degrees >= 158 && _degrees <= 180) || (_degrees >= -179 && _degrees <= -158))
			{
				_primaryKeyCode = Keyboard.LEFT;
			}
			// Thumb stick position - Up			
			else if(_degrees >= -112 && _degrees <= -68)
			{
				_primaryKeyCode = Keyboard.UP;	
			}
			// Thumb stick position - Up/Left				
			else if(_degrees >= -157 && _degrees <= -113)
			{
				_primaryKeyCode = Keyboard.UP;
				_secondaryKeyCode = Keyboard.LEFT;
			}
			// Thumb stick position - Down/Left				
			else if(_degrees <= 157 && _degrees >= 113)
			{
				_primaryKeyCode = Keyboard.DOWN;
				_secondaryKeyCode = Keyboard.LEFT;
			}
			// Thumb stick position - Up/Right				
			else if(_degrees >=-67 && _degrees <= -21)
			{
				_primaryKeyCode = Keyboard.UP;
				_secondaryKeyCode = Keyboard.RIGHT;
			}
			// Thumb stick position - Down/Right				
			else if(_degrees >= 23 && _degrees <= 67)
			{
				_primaryKeyCode = Keyboard.DOWN;
				_secondaryKeyCode = Keyboard.RIGHT;
			}
			
			if(_primaryKeyCode != _previousPrimaryKeyCode)
			{
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, _previousPrimaryKeyCode));
				_previousPrimaryKeyCode = _primaryKeyCode;
			}
			
			if(_previousSecondaryKeyCode != _secondaryKeyCode)
			{
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, _previousSecondaryKeyCode));
				_previousSecondaryKeyCode = _secondaryKeyCode;
			}
			
			if(_secondaryKeyCode > 0)
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, _secondaryKeyCode));
			
			dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, _primaryKeyCode));
		}
		
		protected function killAllEvents():void
		{
			if(_primaryKeyCode)
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, _previousPrimaryKeyCode));
					
			if(_secondaryKeyCode > 0)
				dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, _previousSecondaryKeyCode));
		}
		
		protected function onThumbDown(e:TouchEvent):void
		{
			initDrag();
		}
		
		protected function onThumbUp(e:TouchEvent):void
		{
			resetThumb();
		}
		
				
		protected function onTestThumbDown(e:MouseEvent):void
		{
			initDrag();
		}
		
		protected function onTestThumbUp(e:MouseEvent):void
		{
			resetThumb();
		}
	}
}
