////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.utils
{
	import flash.text.TextFormat;
	
	import mx.core.UITextField;
	
	/**
	 * Utility methods for use with the TextField class.
	 * 
	 * @author Josh Tynjala
	 * @see flash.text.TextField
	 */
	public class UITextFieldUtil
	{
		private static const TEXTFIELD_VERTICAL_MARGIN:Number = 4;
		
		/**
		 * @private
		 * Increases or decreases the font size until the text fills the bounds.
		 * 
		 * @see FontSizeMode
		 */
		public static function autoAdjustFontSize(textField:UITextField, originalSize:Number = 1, mode:String = "noChange"):void
		{
			var format:TextFormat = textField.getTextFormat();
			format.size = originalSize;
			textField.setTextFormat(format);
			textField.validateNow();
			
			if(mode == FontSizeMode.NO_CHANGE || textField.length == 0 ||
				textField.width == 0 || textField.height == 0)
			{
				return;
			}
			
			//increase font size to fit in bounds. stop if the text grows larger than the bounds
			var currentSize:Number = originalSize;
			var sameHeightMeasurement:Boolean = false;
			var lastHeight:Number = 0;
			while(textField.textHeight < (textField.height - TEXTFIELD_VERTICAL_MARGIN))
			{
				if(textField.textHeight == lastHeight)
				{
					//sometimes if the font size is increased by one, the textHeight won't change
					//but then it will change when it is increased again.
					//to combat this problem, we need to check twice
					if(sameHeightMeasurement)
					{
						break;
					}
					sameHeightMeasurement = true;
				}
				else
				{
					sameHeightMeasurement = false;
				}
				lastHeight = textField.textHeight;
				
				currentSize++;
				format.size = currentSize;
				textField.setTextFormat(format);
				textField.validateNow();
				
				//special case when we don't want words to break in the middle
				if(mode == FontSizeMode.FIT_TO_BOUNDS_WITHOUT_BREAKS && textField.numLines > 1)
				{
					//minimize words being broken into multiple lines
					//note: it can still happen if the min font size is too big!
					for(var i:int = 1; i < textField.numLines; i++)
					{
						var lineOffset:int = textField.getLineOffset(i);
						
						//check for a space or dash at the end of the previous line
						var beginningOfLine:String = textField.text.charAt(lineOffset);
						var endOfPreviousLine:String = textField.text.charAt(lineOffset - 1);
						
						if(endOfPreviousLine != " " && endOfPreviousLine != "-" && textField.numLines > 1 && currentSize > 1)
						{
							//why do I have to subtract 2 here?
							//same reason as with the same height flag above?
							currentSize -= 2;
							format.size = currentSize;
							textField.setTextFormat(format);
							textField.validateNow();
							return;
						}
					}
				}
			}
			
			//decrease font size to fit in bounds. stop if the font size reaches 1
			while(currentSize > originalSize && textField.textHeight > (textField.height - TEXTFIELD_VERTICAL_MARGIN))
			{
				currentSize--;
				format.size = currentSize;
				textField.setTextFormat(format);
				textField.validateNow();
			}
		}
		
	}
}