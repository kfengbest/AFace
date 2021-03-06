//
//  ViewController.m
//  AFace
//
//  Created by Kaven Feng on 12/5/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import "ViewController.h"

#import "UIRefreshControl+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "AFNetworking/AFNetworking.h"
#import "MainPageViewController.h"
#import "SharedData.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_background@2x.jpg"]];

    self.userName.delegate = self;
    self.userPsw.delegate = self;
    
    //self.indicator.hidden = TRUE;
    [self.indicator setFrame:CGRectMake(0, 0, 150, 150)];
    self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.indicator setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    self.indicator.backgroundColor = [UIColor grayColor];
    self.indicator.alpha = 0.9;
    self.indicator.layer.cornerRadius = 6;
    self.indicator.layer.masksToBounds = YES;
    self.indicator.hidesWhenStopped = TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    NSString* name = self.userName.text;
    NSString* psw = self.userPsw.text;
    
    [self.userName resignFirstResponder];
    [self.userPsw resignFirstResponder];
    
    [self.indicator startAnimating];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary* parameters=[[NSMutableDictionary alloc] init];
    [parameters setObject: name forKey:@"username"];
    [parameters setObject: psw forKey:@"psw"];
    
    [manager POST:@"http://10.148.252.24/rest-userLogin/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        [self.indicator stopAnimating];
        
        NSDictionary* dic = responseObject;
        BOOL status = [[dic objectForKey:@"status"] boolValue];
        if (status == 0) {
            self.erroMsg.text = @"Login failed. Please check your user name and password";
        }else{
            self.userToken = [dic objectForKey:@"token"];
            [[SharedData theInstance] login:dic];
            [self performSegueWithIdentifier:@"LoginSucceedSegue" sender:self];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.indicator stopAnimating];
        
    }];
    
}

- (IBAction)addFace:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.mediaTypes = temp_MediaTypes;
        picker.delegate = self;
    }
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)faceLogin:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.mediaTypes = temp_MediaTypes;
        picker.delegate = self;
    }
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)listFaces:(id)sender {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString* strUrl = [NSString stringWithFormat:@"http://10.148.252.24/rest-listFaces/?token=%@", self.userToken];

    [manager GET: strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        NSDate* now = [NSDate date];
        NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYYmmddhhmmss"];
        NSString *dateString = [dateFormatter stringFromDate:now];
        [self saveImage:image withFileName:dateString ofType:@"jpg" inDirectory:documentsDirectory];
        self.photoName = [NSString stringWithFormat:@"%@.%@", dateString, @"jpg"];
        
        UIImage *newImage = [self scaleImage:image scaledToSize:0.8];

        self.erroMsg.text = @"Searching your face...";
        [self.indicator startAnimating];

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"Content-Type": @"multipart/form-data"};
        NSString* strUrl = @"http://10.148.252.24/rest-faceLogin/";
        [manager POST: strUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(newImage, 0.6) name:@"file" fileName:self.photoName mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            [self.indicator stopAnimating];

            NSDictionary* dic = responseObject;
            BOOL status = [[dic objectForKey:@"status"] boolValue];
            if (status == 0) {
                self.erroMsg.text = @"Face not matched. Please take photo again.";
                
            }else{
                float fConfidence = [[dic objectForKey:@"confidence"] floatValue];
                if (fConfidence > 15.0) {
                    self.erroMsg.text = @"";
                    
                    self.userToken = [dic objectForKey:@"token"];
                    [[SharedData theInstance] login:dic];
                    [self performSegueWithIdentifier:@"LoginSucceedSegue" sender:self];
                }else{
                    self.erroMsg.text = @"Face not matched. Please take photo again.";
                }

            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.erroMsg.text = @"Network access error.";

            [self.indicator stopAnimating];

        }];
        

    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:
(NSError *)error contextInfo:(void *)contextInfo;
{
    // Handle the end of the image write process
    if (!error)
        NSLog(@"Image written to photo album %@", contextInfo);
    else
        NSLog(@"Error writing to photo album: %@",
              [error localizedDescription]);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"exceptional file type.");
    }
}

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", directoryPath, fileName, extension]];
    
    return result;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.userName resignFirstResponder];
    [self.userPsw resignFirstResponder];

    return YES;
}

- (UIImage *)scaleImage:(UIImage *)image scaledToSize:(float)scaleFactor {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    
    float w =image.size.width;
    float h = image.size.height;
    CGSize newSize = CGSizeMake( w * scaleFactor, h * scaleFactor);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
