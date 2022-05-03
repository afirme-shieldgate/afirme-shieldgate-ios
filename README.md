**

Payment SDK IOS
-----------------

**


----------
### Requerimientos

*Version <= 1.4.x*
- iOS 9.0 or Later
- Xcode 9

*Version >= 1.5.x*
- iOS 9.0 or Later
- Xcode 10


**Dependencias:**

Accelerate
AudioToolbox
AVFoundation
CoreGraphics
CoreMedia
CoreVideo
Foundation
MobileCoreServices
OpenGLES
QuartzCore
Security
UIKit
CommonCrypto (Just for version 1.4)


**Project Configuration**
- ObjC in other linker flags in target
- lc++ in target other linker flags
- Disable Bitcode


----------
# INSTALACIÓN

**Carthage**

Si no tienes instalado, Instala la última versión de [Carthage](https://github.com/Carthage/Carthage)

Agrega esta línea en Cartfile:

``` git "https://github.com/afirme-shieldgate/afirme-shieldgate-ios" ```

Beta Version:

``` git "https://github.com/afirme-shieldgate/afirme-shieldgate-ios" "master" ```


**ObjC configuración**

Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

In Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

# **Instalación manual(Recomendad)**









Este SDK es un framework dinámico ([Información](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html)). Debes genera una versión para el target deseado (simulator and device). Sigue estos pasos para crear una versión universal .framework file.

1. Compila el SDK & crea .framework files

Esto crearña un folder /build donde estarán los archivos .framework necesarios (simulator, iphoneos & universal)
 
- Con el Target PaymentSDK seleccionado, compila el proyecto para cualquier simulador iOS.
- Con el Target PaymentSDK seleccionado, compila el proyecto para Any iOS device

After

- Cont el Target PaymentSDK-Universal,  compila el proyecto en any iOS device. 
- Ingresa a la carpeta Products -> PaymentSDK.framework -> Show in finder
- Ingresa al directorio de PaymentSDK.framework, CMD+up
- Se visualizarán 3 grupos, dentro del grupo Release-iosuniversal, estará el PaymentSDK.framework

- O si prefieres puedes descargar un compilado .framework desde [Releases](https://github.com/afirme-shieldgate/afirme-shieldgate-ios)


2. Arrastra el PaymentSDK.framework a tu proyecto check "Copy Files if needed".

En Target->General : Agrega PaymentSDK.framework a Frameworks, Libraries, and Embedded Content

En Target->Build Settings : Validate Workspace debe ser YES

3. Actualiza el Build Settings with

Set ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES

En Build Phases -> Embed Frameworks Uncheck "Copy Only When Installing"

4. Si usas la versión Universal y quieres subir a la appstore. Agrega Run Script Phase: Target->Build Phases -> + ->New Run Script Phase. Agrega lo siguiente.Asegurate que el build phase esta agregado después Embed Frameworks phase.
```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/PaymentSDK.framework/install_dynamic.sh"
```

----------
**Usage**

Importing Swift

import PaymentSDK

Configura tu app inside AppDelegate->didFinishLaunchingWithOptions. Debes usar el Payment Client Credentials (Just ADD enabled)

PaymentSDKClient.setEnvironment("AbiColApp", secretKey: "2PmoFfjZJzjKTnuSYCFySMfHlOIBz7", testMode: true)


# Types of implementation

Hay tres formas de presentar el Add Card Form:

1. Como un Widget en un Custom View
2. Como un Viewcontroller Pushed a tu UINavigationController
3. Como un ViewController  presentado en Modal

El AddCard Form incluye: Card io scan, y validación de tarjeta.

## Show AddCard Widget

Para crear un widget, debe crear un PaymentAddNativeController desde PaymentSDKClient. Luego agréguelo a la UIView que será el contenedor del Formulario de Pago. La altura mínima debe ser de 300 px y la pantalla completa como ancho (270 px sin el logotipo de pago)

**Note:**  *Cuando está utilizando el Formulario de Pago como Widget. El ViewController personalizado del Cliente será responsable del diseño y la sincronización (también conocido como Spinner o loader).)*

El widget puede escanear con la cámara de su teléfono los datos de la tarjeta de crédito usando card.io.

```swift
let paymentAddVC = self.addPaymentWidget(toView: self.addView, delegate: nil, uid:UserModel.uid, email:UserModel.email)

```

Objc

```objc


[self addPaymentWidgetToView:self. addView delegate:self uid:@"myuid" email:@"myemail"];

```
Recupere la tarjeta de crédito válida de PaymentAddNativeController (Widget):

```swift
if let validCard = paymentAddVC.getValidCard() // CHECK IF THE CARD IS VALID, IF THERE IS A VALIDATION ERROR NIL VALUE WILL BE RETURNED
{
sender?.isEnabled = false
PaymentSDKClient.createToken(validCard, uid: UserModel.uid, email: UserModel.email, callback: { (error, cardAdded) in

if cardAdded != nil // handle the card status
{
}
else if error != nil //handle the error
{
}
})
}
```

Objc
```objc
PaymentCard *validCard = [self.paymentAddVC getValidCard];
if (validCard != nil) // Check if it is avalid card
{

[PaymentSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentSDKError *error, PaymentCard *cardAdded) {
[sender setEnabled:YES];
if(cardAdded != nil) // handle the card status
{

}
else  //handle the error
{

}
}];
}
```
## Pushed to your NavigationController


```swift
self.navigationController?.pushPaymentViewController(delegate: self, uid: UserModel.uid, email: UserModel.email)

```

Objc

```objc


[self.navigationController pushPaymentViewControllerWithDelegate:self uid:@"myuid" email:@"mymail@mail.com"]`;
```

## Present as Modal


```swift
self.presentPaymentViewController(delegate: self, uid: "myuid", email: "myemail@email.com")

```

Objc

```objc

[self presentPaymentViewControllerWithDelegate:self uid:@"myuid" email:@"myemail@email.com"];
```


###  PaymentCardAddedDelegate Protocol

Si presenta el formulario como un controlador de vista (push y modal), debe implementar el protocolo PaymetnezCardAddedDelegate para manejar los estados o acciones dentro del controlador de vista. Si está utilizando la implementación de Widget, puede manejar las acciones como se describe anteriormente.

```swift
protocol PaymentCardAddedDelegate
{
func cardAdded(_ error:PaymentSDKError?, _ cardAdded:PaymentCard?)
func viewClosed()
}
```
`func cardAdded(_ error:PaymentSDKError?, _ cardAdded:PaymentCard?)`  is called whenever there is an error or a card is added.

`func viewClosed()`  Whenever the modal is closed


### Scan Card
Si quieres hacer el escaneo tú mismo, usa card.io

```swift
PaymentSDKClient.scanCard(self) { (closed, number, expiry, cvv, card) in
if !closed // user did not closed the scan card dialog
{
if card != nil  // paymentcard object to handle the data
{

}
})
```

-ObjC
```objc
[PaymentSDKClient scanCard:self callback:^(BOOL userClosed, NSString *cardNumber, NSString *expiryDate, NSString *cvv, PaymentCard *card) {

if (!userClosed) //user did not close the scan card dialog
{
if (card != nil) // Handle card
{

}

}
}];
```

### Add Card (Only PCI Integrations)

Para integraciones de formularios personalizados
Campos obligatorios
+ cardNumber: número de tarjeta como una cadena sin separadores, p. 4111111111111111.
+ titular de la tarjeta: nombre del titular de la tarjeta.
+ expuryMonth: número entero que representa el mes de vencimiento de la tarjeta, 01-12.
+ expirationYear: número entero que representa el año de vencimiento de la tarjeta, p. 2020.
+ cvc: código de seguridad de la tarjeta en forma de cadena, p. '123'.

```swift
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")

if card != nil  // A valid card was created
{
PaymentSDKClient.add(card, uid: "69123", email: "test@shielgate.mx", callback: { (error, cardAdded) in

if cardAdded != nil
{
//the request was succesfully sent, you should check the cardAdded status
}

})
}
else
{
//handle invalid card
}
```

ObjC

```objc
PaymentCard *validCard = [PaymentCard createCardWithCardHolder:@"Gustavo Sotelo" cardNumber:@"4111111111111111" expiryMonth:10 expiryYear:2020 cvc:@"123"];
if (validCard != nil) // Check if it is avalid card
{

[PaymentSDKClient add:validCard uid:USERMODEL_UID email:USERMODEL_EMAIL callback:^(PaymentSDKError *error, PaymentCard *cardAdded) {
[sender setEnabled:YES];
if(cardAdded != nil) // handle the card status
{

}
else  //handle the error
{

}
}];
}

```


### Secure Session Id

Las acciones de débito deben implementarse en su propio backend. Por razones de seguridad, proporcionamos una generación de identificación de sesión segura, para sistemas de fraude de cuentas. Esto recopilará la información del dispositivo en segundo plano.

```swift
let sessionId = PaymentSDKClient.getSecureSessionId()
```
Objc

```objc
NSString *sessionId = [PaymentSDKClient getSecureSessionId];
```

### Utils

Get Card Assets

```swift
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
if card != nil  // A valid card was created
{
let image = card.getCardTypeAsset()

}
```

Get Card Type (Just Amex, Mastercard, Visa, Diners)
```swift
let card = PaymentCard.createCard(cardHolder:"Gustavo Sotelo", cardNumber:"4111111111111111", expiryMonth:10, expiryYear:2020, cvc:"123")
if card != nil  // A valid card was created
{
switch(card.cardType)
{
case .amex:
case .masterCard:
case .visa:
case .diners:
default:
//not supported action
}

}
```

### Customize Look & Feel 


You can customize widget colors sample 

```swift
paymentAddVC.baseFontColor = .white
paymentAddVC.baseColor = .green
paymentAddVC.backgroundColor = .white
paymentAddVC.showLogo = false
paymentAddVC.baseFont = UIFont(name: "Your Font", size: 12) ?? UIFont.systemFont(ofSize: 12)

```

Los elementos personalizables del formulario son los siguientes:

- `baseFontColor` : El color de la fuente de los campos
- `baseColor`: Color de las líneas y títulos de los campos
- `backgroundColor`: color de fondo del widget
- `showLogo`: habilitar o deshabilitar el logotipo de pago
- `baseFont`: Fuente de todo el formulario
- `nameTitle`: cadena para el marcador de posición personalizado para el campo de nombre
- `cardTitle`: cadena para el marcador de posición personalizado para el campo de la tarjeta
- `invalidCardTitle` para el mensaje de error cuando un número de tarjeta no es válido


### Building and Running the PaymentSwift

Before you can run the PaymentStore application, you need to provide it with your APP_CODE, APP_SECRET_KEY and a sample backend.

Antes de poder ejecutar la aplicación PaymentStore, debe proporcionarle su APP_CODE, APP_SECRET_KEY y un backend de muestra.

1. Si aún no lo ha hecho y APP_CODE y APP_SECRET_KEY, solicítelo a su contacto en el Equipo de pagos.
2. Reemplace `PAYMENT_APP_CODE` y `PAYMENT_APP_SECRET_KEY` en su AppDelegate como se muestra en la sección Uso
3. Diríjase a https://github.com/afirme-shieldgate/example-java-backend y haga clic en "Implementar en Heroku" (es posible que deba registrarse para obtener una cuenta de Heroku como parte de este proceso). Proporcione los campos APP_CODE y APP_SECRET_KEY de sus credenciales de servidor de Paymentz en 'Env'. Haga clic en "Implementar gratis".
4. Reemplace la variable `BACKEND_URL` en MyBackendLib.swift (dentro de la variable myBackendUrl) con la URL de la aplicación que Heroku le proporciona (por ejemplo, "https://my-example-app.herokuapp.com")
5. Reemplace las variables (uid y correo electrónico) en UserModel.swift con su propia referencia de identificación de usuario
