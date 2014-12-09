//
//  MyPageViewController.m
//  AFace
//
//  Created by Kaven Feng on 12/9/14.
//  Copyright (c) 2014 Kaven Feng. All rights reserved.
//

#import "MyPageViewController.h"

#import "AFNetworking/AFNetworking.h"
#import "SharedData.h"

@interface MyPageViewController ()

@end

@implementation MyPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)listFaces:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString* token = [[SharedData theInstance] getToken];
    NSString* strUrl = [NSString stringWithFormat:@"http://10.148.252.24/rest-listFaces/?token=%@", token];
    
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
         NSString * imageName = [NSString stringWithFormat:@"%@.%@", dateString, @"jpg"];
        [self saveImage:image withFileName:dateString ofType:@"jpg" inDirectory:documentsDirectory];
        
 //       UIImage *newImage = [self imageWithImage:image scaledToSize:CGSizeMake(320, 480)];
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"Content-Type": @"multipart/form-data"};
        NSString* token = [[SharedData theInstance] getToken];
        NSString* strUrl = [NSString stringWithFormat:@"http://10.148.252.24:80/rest-bindFace/?token=%@", token];
                [manager POST: strUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"file" fileName: imageName mimeType:@"image/jpeg"];
    
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Success: %@", responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
        


        
        
        //        PhotoItem* newItem = [[PhotoItem alloc] init];
        //        newItem.imageName = dateString;
        //        newItem.category = nil;
        //        [mImages addObject:newItem];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //    [self.collectionView reloadData];
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

@end
