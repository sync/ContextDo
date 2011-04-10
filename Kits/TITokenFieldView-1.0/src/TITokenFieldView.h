//
//  TITokenFieldView.h
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//		   conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//         of conditions and the following disclaimer in the documentation and/or other materials
//         provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOM IRVING "AS IS" AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOM IRVING OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>

@class TITokenField, TIToken;

//==========================================================
// - Delegate Methods
//==========================================================

@protocol TITokenDelegate <NSObject>
@optional
- (void)tokenGotFocus:(TIToken *)token;
- (void)tokenLostFocus:(TIToken *)token;
@end

@protocol TITokenFieldDelegate <UIScrollViewDelegate>
@optional
- (void)tokenField:(TITokenField *)tokenField tokenTouched:(TIToken *)token;
- (void)tokenFieldDidBeginEditing:(TITokenField *)tokenField;
- (void)tokenFieldDidEndEditing:(TITokenField *)tokenField;
@end

//==========================================================
// - TITokenField
//==========================================================

@interface TITokenField : UIScrollView <TITokenDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {

	CGPoint cursorLocation;
}

@property (nonatomic, readonly, retain) NSMutableArray * tokensArray;
@property (nonatomic, readonly) int numberOfLines;
@property (nonatomic, assign) id <TITokenFieldDelegate> delegate;
@property (nonatomic, retain) NSString *promptText;


- (void)addToken:(NSString *)title;
- (void)removeToken:(TIToken *)token;

@end

//==========================================================
// - TIToken
//==========================================================

@interface TIToken : UIView {
	
}

@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * croppedTitle;
@property (nonatomic, assign) id <TITokenDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle;

@end
