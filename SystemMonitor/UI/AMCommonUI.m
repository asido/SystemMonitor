//
//  AMCommonUI.m
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Arvydas Sidorenko
//

#import "AMCommonUI.h"

@implementation AMCommonUI

+ (UIView *)mainMenuBackgroundView
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainMenuBackground"]];
    background.contentMode = UIViewContentModeCenter;
    return background;
}

+ (UIView *)sectionBackgroundView
{
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ViewBackground-1496"]];
    background.contentMode = UIViewContentModeCenter;
    return background;
}

+ (UIView *)showActionSheetSimulationInViewController:(UIViewController *)viewController WithPickerView:(UIPickerView *)pickerView withToolbar:(UIToolbar *)pickerToolbar
{
    UIView* simulatedActionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                UIScreen.mainScreen.bounds.size.width,
                                                                                UIScreen.mainScreen.bounds.size.height)];
    [simulatedActionSheetView setBackgroundColor:[UIColor clearColor]];
    
    CGFloat pickerViewYpositionHidden = UIScreen.mainScreen.bounds.size.height + pickerToolbar.frame.size.height;
    CGFloat pickerViewYposition = UIScreen.mainScreen.bounds.size.height - pickerView.frame.size.height + UIApplication.sharedApplication.statusBarFrame.size.height;
    [pickerView setFrame:CGRectMake(pickerView.frame.origin.x,
                                    pickerViewYpositionHidden,
                                    pickerView.frame.size.width,
                                    pickerView.frame.size.height)];
    [pickerToolbar setFrame:CGRectMake(pickerToolbar.frame.origin.x,
                                       pickerViewYpositionHidden,
                                       pickerToolbar.frame.size.width,
                                       pickerToolbar.frame.size.height)];
    pickerView.backgroundColor = [UIColor whiteColor];
    [simulatedActionSheetView addSubview:pickerToolbar];
    [simulatedActionSheetView addSubview:pickerView];
    
    [UIApplication.sharedApplication.keyWindow?UIApplication.sharedApplication.keyWindow:UIApplication.sharedApplication.windows[0]
                                                                              addSubview:simulatedActionSheetView];
    [simulatedActionSheetView.superview bringSubviewToFront:simulatedActionSheetView];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [simulatedActionSheetView setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.5]];
                         [viewController.view setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
                         [viewController.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
                         [pickerView setFrame:CGRectMake(pickerView.frame.origin.x,
                                                         pickerViewYposition,
                                                         pickerView.frame.size.width,
                                                         pickerView.frame.size.height)];
                         [pickerToolbar setFrame:CGRectMake(pickerToolbar.frame.origin.x,
                                                            pickerViewYposition - pickerToolbar.frame.size.height,
                                                            pickerToolbar.frame.size.width,
                                                            pickerToolbar.frame.size.height)];
                     }
                     completion:nil];
    
    return simulatedActionSheetView;
}

+ (void)dismissActionSheetSimulationInViewController:(UIViewController *)viewController simulation:(UIView*)actionSheetSimulation
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [actionSheetSimulation setBackgroundColor:[UIColor clearColor]];
                         [viewController.view setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
                         [viewController.navigationController.navigationBar setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
                         [actionSheetSimulation.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                             UIView* v = (UIView*)obj;
                             [v setFrame:CGRectMake(v.frame.origin.x,
                                                    UIScreen.mainScreen.bounds.size.height,
                                                    v.frame.size.width,
                                                    v.frame.size.height)];
                         }];
                     }
                     completion:^(BOOL finished) {
                         [actionSheetSimulation removeFromSuperview];
                     }];
    
}


@end
