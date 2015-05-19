# UIPlacePicker

UIPlacePicker is a UIViewController where the user can pick a location from a map or entering the complete address.

## Features

* Support iOS 6.0 and above.
* Use iOS 4 MapKit built-in draggable support
* Use Google services to determinate a location from an address and to determinate the address from one location
* It works like UIImagePickerViewController, with delegates.

## Screenshot

![](https://github.com/AlbertMontserratGambus/UIPlacePicker/blob/master/Screenshot1.png)

![](https://github.com/AlbertMontserratGambus/UIPlacePicker/blob/master/Screenshot2.png)

## How it works

To open a new UIPlacePicker just do:

```
picker = [[UIPlacePicker alloc] initWithUIPlace:nil];
picker.delegate = self;
    
[self presentViewController:picker animated:YES completion:^{
        
}];
```

You must implement the delegates functions:

```
-(void)placePickerDidSelectPlace:(UIPlace *)__place{
    UIPlace *place = __place;
    [self hidePlacePicker];
}

-(void)placePickerDidCancel{
    [self hidePlacePicker];
}

-(void)hidePlacePicker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
```

When you hace already a UIPlace, you can also call the UIPlacePicker with this place pre-loaded:

```
picker = [[UIPlacePicker alloc] initWithUIPlace:place];
picker.delegate = self;
    
[self presentViewController:picker animated:YES completion:^{
        
}];
```

And if you want only to show the place and disable the edit functionalities, just do:

```
picker = [[UIPlacePicker alloc] initWithUIPlaceOnlyVisitor:place];
picker.delegate = self;
    
[self presentViewController:picker animated:YES completion:^{
        
}];
```

## License 

This project is released under MIT License.
