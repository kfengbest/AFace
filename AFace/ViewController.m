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
    
    self.userName.delegate = self;
    self.userPsw.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    NSString* name = self.userName.text;
    NSString* psw = self.userPsw.text;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary* parameters=[[NSMutableDictionary alloc] init];
    [parameters setObject: name forKey:@"username"];
    [parameters setObject: psw forKey:@"psw"];
    
    [manager POST:@"http://10.148.252.24/rest-userLogin/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        NSDictionary* dic = responseObject;
        BOOL status = (BOOL)[dic objectForKey:@"status"];
        if (status != nil && status == FALSE) {
            self.erroMsg.text = @"Login failed. Please check your user name and password";
        }else{
            self.userToken = [dic objectForKey:@"token"];
            [[SharedData theInstance] login:dic];
            [self performSegueWithIdentifier:@"LoginSucceedSegue" sender:self];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
        
        UIImage *newImage = [self imageWithImage:image scaledToSize:CGSizeMake(320, 480)];

        self.erroMsg.text = @"Searching your face for login...";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"Content-Type": @"multipart/form-data"};
        NSString* strUrl = @"http://10.148.252.24/rest-faceLogin/";
        [manager POST: strUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(newImage, 1.0) name:@"file" fileName:self.photoName mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            
            NSDictionary* dic = responseObject;
            BOOL status = (BOOL)[dic objectForKey:@"status"];
            if (status != nil && status == FALSE) {
                self.erroMsg.text = @"Login failed. Please take a photo again.";
                
            }else{
                self.erroMsg.text = @"";

                self.userToken = [dic objectForKey:@"token"];
                [[SharedData theInstance] login:dic];
                [self performSegueWithIdentifier:@"LoginSucceedSegue" sender:self];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
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

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
