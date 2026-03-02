<a name="e_commerce_email_organizer_flutte_f4ccd7"></a>**E-Commerce Email Organizer - Flutter App Development Guide**

**Project Overview:** A Flutter mobile application that uses Google OAuth to access user emails, identifies e-commerce related emails using machine learning or keyword-based classification, and displays them in an organized dashboard.

**Author:** Shahid Patel\
**Date:** March 2, 2026\
**Target Platform:** Android/iOS (Flutter)

-----
<a name="introduction"></a>**Introduction**

This document provides a comprehensive guide for building an e-commerce email organizer app using Flutter. The app addresses a common problem: e-commerce emails often end up in spam or promotional folders, making it difficult to track orders, shipping updates, and important notifications.

The solution involves integrating Google OAuth for authentication, accessing Gmail API with appropriate scopes, classifying emails using either a lightweight Hugging Face model or keyword-based detection, and presenting the results in a user-friendly dashboard.

Since you're new to Flutter, this guide includes step-by-step setup instructions, architecture recommendations, and code patterns to help you get started.

-----
<a name="project_requirements"></a>**Project Requirements**

<a name="functional_requirements"></a>**Functional Requirements**

1. User authentication via Google OAuth
1. Request Gmail API access with email reading permissions
1. Fetch emails from user's Gmail account
1. Classify emails as e-commerce or non-e-commerce
1. Display classified e-commerce emails in a dashboard
1. Filter emails by categories (orders, shipping, promotions, etc.)
1. Handle spam and promotional folder emails

<a name="technical_requirements"></a>**Technical Requirements**

1. Flutter framework for cross-platform development
1. Google Sign-In integration
1. Gmail API integration with appropriate scopes
1. Email classification (Hugging Face model or keyword-based)
1. No external AI API usage (Hugging Face inference on-device or keyword approach)
1. Local data processing and caching

<a name="technical_constraints"></a>**Technical Constraints**

1. No paid AI APIs (OpenAI, Claude, etc.)
1. Classification must work offline or with free models
1. Must handle Gmail API rate limits
1. Privacy-focused: process emails locally
-----
<a name="technology_stack"></a>**Technology Stack**

<a name="core_technologies"></a>**Core Technologies**

|Component|Technology|
| :- | :- |
|Framework|Flutter 3.24+|
|Language|Dart 3.0+|
|Authentication|Google Sign-In|
|Email Access|Gmail API v1|
|Classification|Hugging Face model or Keywords|
|State Management|Provider or Riverpod|
|Local Storage|SharedPreferences / Hive|
|HTTP Client|http or dio package|

Table 1: Technology stack components

<a name="required_flutter_packages"></a>**Required Flutter Packages**

1. **google\_sign\_in** (^7.2.0) - Google OAuth authentication
1. **googleapis** (^16.0.0) - Gmail API access
1. **googleapis\_auth** (^1.6.0) - OAuth credentials management
1. **http** (^1.2.0) - HTTP requests
1. **provider** (^6.1.0) - State management
1. **shared\_preferences** (^2.2.0) - Local data storage
1. **flutter\_dotenv** (^5.1.0) - Environment variables

<a name="optional_packages_for_ml_approach"></a>**Optional Packages for ML Approach**

1. **tflite\_flutter** (^0.10.0) - TensorFlow Lite for on-device inference
1. **onnxruntime** (^1.16.0) - ONNX model runtime for Hugging Face models
-----
<a name="system_architecture"></a>**System Architecture**

<a name="high_level_architecture"></a>**High-Level Architecture**

The app follows a three-tier architecture:

1. **Presentation Layer** - Flutter UI widgets and screens
1. **Business Logic Layer** - Email classification and processing
1. **Data Layer** - Gmail API integration and local storage

<a name="component_diagram"></a>**Component Diagram**

┌─────────────────────────────────────────┐\
│ Flutter UI Layer │\
│ (Dashboard, Email List, Filters) │\
└─────────────────┬───────────────────────┘\
│\
┌─────────────────▼───────────────────────┐\
│ Business Logic Layer │\
│ - Email Classifier │\
│ - Category Manager │\
│ - Cache Manager │\
└─────────────────┬───────────────────────┘\
│\
┌─────────────────▼───────────────────────┐\
│ Data Layer │\
│ - Gmail API Service │\
│ - Google Auth Service │\
│ - Local Storage │\
└─────────────────────────────────────────┘

<a name="data_flow"></a>**Data Flow**

1. User logs in with Google OAuth
1. App requests Gmail API access with readonly scope
1. Gmail API fetches emails (with pagination)
1. Email classifier processes email content
1. Classified emails stored locally with categories
1. UI displays filtered e-commerce emails
-----
<a name="flutter_setup_guide"></a>**Flutter Setup Guide**

<a name="installation_prerequisites"></a>**Installation Prerequisites**

Before starting development, ensure you have:

1. Flutter SDK 3.24 or higher
1. Dart 3.0 or higher
1. Android Studio / VS Code with Flutter extensions
1. Android SDK (for Android development)
1. Xcode (for iOS development, macOS only)
1. Git for version control

<a name="flutter_installation_steps"></a>**Flutter Installation Steps**

1. Download Flutter SDK from <https://docs.flutter.dev/get-started/install>
1. Extract the archive and add Flutter to your PATH
1. Run flutter doctor to verify installation
1. Install missing dependencies as indicated
1. Configure IDE with Flutter and Dart plugins

<a name="project_creation"></a>**Project Creation**

<a name="create_new_flutter_project"></a>**Create new Flutter project**

flutter create ecommerce\_email\_organizer

<a name="navigate_to_project_directory"></a>**Navigate to project directory**

cd ecommerce\_email\_organizer

<a name="open_in_vs_code_or_android_studio"></a>**Open in VS Code or Android Studio**

code .

<a name="project_structure"></a>**Project Structure**

ecommerce\_email\_organizer/\
├── lib/\
│ ├── main.dart\
│ ├── models/\
│ │ ├── email\_model.dart\
│ │ └── user\_model.dart\
│ ├── services/\
│ │ ├── auth\_service.dart\
│ │ ├── gmail\_service.dart\
│ │ └── classifier\_service.dart\
│ ├── providers/\
│ │ └── email\_provider.dart\
│ ├── screens/\
│ │ ├── login\_screen.dart\
│ │ ├── dashboard\_screen.dart\
│ │ └── email\_detail\_screen.dart\
│ └── widgets/\
│ ├── email\_card.dart\
│ └── category\_filter.dart\
├── android/\
├── ios/\
└── pubspec.yaml

-----
<a name="google_oauth_integration"></a>**Google OAuth Integration**

<a name="google_cloud_console_setup"></a>**Google Cloud Console Setup**

1. Go to <https://console.cloud.google.com/>
1. Create a new project or select existing
1. Enable Gmail API in "APIs & Services"
1. Navigate to "Credentials" section
1. Create OAuth 2.0 Client ID
1. Configure OAuth consent screen
1. Add authorized domains
1. Download credentials JSON

<a name="oauth_scopes_required"></a>**OAuth Scopes Required**

The app needs the following Gmail API scopes:

1. https://www.googleapis.com/auth/gmail.readonly - Read email messages
1. https://www.googleapis.com/auth/gmail.labels - Access email labels

**Note:** Use gmail.readonly instead of gmail.modify to minimize permission scope and improve user trust.

<a name="android_configuration"></a>**Android Configuration**

Edit android/app/build.gradle:

android {\
defaultConfig {\
minSdkVersion 21 // Required for google\_sign\_in\
targetSdkVersion 34\
}\
}

Add Google Services JSON to android/app/google-services.json (obtained from Firebase Console or Google Cloud Console).

<a name="ios_configuration"></a>**iOS Configuration**

Edit ios/Runner/Info.plist:

CFBundleURLTypes CFBundleTypeRole Editor CFBundleURLSchemes com.googleusercontent.apps.YOUR\_CLIENT\_ID

Replace YOUR\_CLIENT\_ID with your OAuth client ID.

<a name="authentication_service_implementation"></a>**Authentication Service Implementation**

// lib/services/auth\_service.dart\
import 'package:google\_sign\_in/google\_sign\_in.dart';\
import 'package:googleapis\_auth/googleapis\_auth.dart';

class AuthService {\
final GoogleSignIn \_googleSignIn = GoogleSignIn(\
scopes: [\
'<https://www.googleapis.com/auth/gmail.readonly>',\
'<https://www.googleapis.com/auth/gmail.labels>',\
],\
);

Future<GoogleSignInAccount?> signIn() async {\
try {\
final account = await \_googleSignIn.signIn();\
return account;\
} catch (error) {\
print('Sign in error: $error');\
return null;\
}\
}

Future<void> signOut() async {\
await \_googleSignIn.signOut();\
}

Future<AuthClient?> getAuthClient() async {\
final account = await \_googleSignIn.signInSilently();\
if (account == null) return null;

final auth = await account.authentication;\
final credentials = AccessCredentials(\
`  `AccessToken('Bearer', auth.accessToken!, \
`    `DateTime.now().add(Duration(hours: 1))),\
`  `null,\
`  `['https://www.googleapis.com/auth/gmail.readonly'],\
);\
\
return authenticatedClient(Client(), credentials);

}\
}

-----
<a name="gmail_api_integration"></a>**Gmail API Integration**

<a name="gmail_service_setup"></a>**Gmail Service Setup**

The Gmail API provides methods to list, read, and filter emails. The key endpoints we'll use are:

1. users.messages.list() - Fetch list of message IDs
1. users.messages.get() - Get full message details
1. users.labels.list() - List available labels

<a name="gmail_service_implementation"></a>**Gmail Service Implementation**

// lib/services/gmail\_service.dart\
import 'package:googleapis/gmail/v1.dart';\
import 'package:http/http.dart' as http;

class GmailService {\
GmailApi? \_gmailApi;

Future<void> initialize(http.Client authClient) async {\
\_gmailApi = GmailApi(authClient);\
}

Future<List<Message>> fetchEmails({\
int maxResults = 100,\
String? pageToken,\
}) async {\
if (\_gmailApi == null) {\
throw Exception('Gmail API not initialized');\
}

try {\
`  `final response = await \_gmailApi!.users.messages.list(\
`    `'me',\
`    `maxResults: maxResults,\
`    `pageToken: pageToken,\
`  `);\
\
`  `final messageIds = response.messages ?? [];\
`  `final messages = <Message>[];\
\
`  `// Fetch full details for each message\
`  `for (final messageRef in messageIds) {\
`    `final message = await \_gmailApi!.users.messages.get(\
`      `'me',\
`      `messageRef.id!,\
`      `format: 'full',\
`    `);\
`    `messages.add(message);\
`  `}\
\
`  `return messages;\
} catch (e) {\
`  `print('Error fetching emails: $e');\
`  `return [];\
}

}

Future<List<Message>> fetchEmailsByLabel(String labelId) async {\
if (\_gmailApi == null) {\
throw Exception('Gmail API not initialized');\
}

try {\
`  `final response = await \_gmailApi!.users.messages.list(\
`    `'me',\
`    `labelIds: [labelId],\
`    `maxResults: 50,\
`  `);\
\
`  `// Fetch full message details\
`  `final messages = <Message>[];\
`  `for (final msg in response.messages ?? []) {\
`    `final fullMsg = await \_gmailApi!.users.messages.get(\
`      `'me',\
`      `msg.id!,\
`      `format: 'full',\
`    `);\
`    `messages.add(fullMsg);\
`  `}\
\
`  `return messages;\
} catch (e) {\
`  `print('Error fetching by label: $e');\
`  `return [];\
}

}\
}

<a name="email_model"></a>**Email Model**

// lib/models/email\_model.dart\
class EmailModel {\
final String id;\
final String subject;\
final String sender;\
final String snippet;\
final DateTime date;\
final String body;\
final bool isEcommerce;\
final String category; // 'order', 'shipping', 'promotion', 'other'

EmailModel({\
required [this.id](http://this.id),\
required this.subject,\
required this.sender,\
required this.snippet,\
required this.date,\
required this.body,\
this.isEcommerce = false,\
this.category = 'other',\
});

factory EmailModel.fromGmailMessage(Message message) {\
final headers = message.payload?.headers ?? [];

String getHeader(String name) {\
`  `return headers\
.firstWhere(\
`        `(h) => h.name?.toLowerCase() == name.toLowerCase(),\
`        `orElse: () => MessagePartHeader(value: ''),\
`      `)\
.value ?? '';\
}\
\
return EmailModel(\
`  `id: message.id ?? '',\
`  `subject: getHeader('subject'),\
`  `sender: getHeader('from'),\
`  `snippet: message.snippet ?? '',\
`  `date: DateTime.fromMillisecondsSinceEpoch(\
`    `int.parse(message.internalDate ?? '0'),\
`  `),\
`  `body: \_extractBody(message.payload),\
);

}

static String \_extractBody(MessagePart? payload) {\
if (payload?.body?.data != null) {\
return payload!.body!.data!;\
}\
if (payload?.parts != null) {\
for (final part in payload!.parts!) {\
if (part.mimeType == 'text/plain' || part.mimeType == 'text/html') {\
return part.body?.data ?? '';\
}\
}\
}\
return '';\
}\
}

-----
<a name="email_classification_approaches"></a>**Email Classification Approaches**

You have two primary options for classifying emails: keyword-based detection or machine learning models from Hugging Face.

<a name="option_1_keyword_based_classifica_1e8314"></a>**Option 1: Keyword-Based Classification (Recommended for Beginners)**

This approach uses pattern matching and keyword detection. It's simpler, faster, and doesn't require ML infrastructure.

<a name="e_commerce_email_patterns"></a>**E-commerce Email Patterns**

|Category|Keywords & Patterns|
| :- | :- |
|Order Confirmation|order, purchase, receipt, transaction, confirmed|
|Shipping|shipped, tracking, delivery, dispatched, courier|
|Promotions|sale, discount, offer, coupon, deal, %off|
|Account|account, verify, reset, password, welcome|
|Returns|return, refund, exchange, cancel|

Table 2: E-commerce keyword patterns

<a name="common_e_commerce_domains"></a>**Common E-commerce Domains**

1. [amazon.com](http://amazon.com), [flipkart.com](http://flipkart.com), [myntra.com](http://myntra.com)
1. [ebay.com](http://ebay.com), [alibaba.com](http://alibaba.com), [shopify.com](http://shopify.com)
1. [ajio.com](http://ajio.com), [nykaa.com](http://nykaa.com), [meesho.com](http://meesho.com)
1. [zomato.com](http://zomato.com), [swiggy.com](http://swiggy.com), [bigbasket.com](http://bigbasket.com)

<a name="classifier_implementation"></a>**Classifier Implementation**

// lib/services/classifier\_service.dart\
class ClassifierService {\
// E-commerce domains\
static const ecommerceDomains = [\
'amazon', 'flipkart', 'myntra', 'ebay', 'shopify',\
'ajio', 'nykaa', 'meesho', 'zomato', 'swiggy',\
'bigbasket', 'alibaba', 'etsy', 'walmart',\
];

// Keywords by category\
static const orderKeywords = [\
'order', 'purchase', 'receipt', 'transaction',\
'invoice', 'payment', 'confirmed', 'placed'\
];

static const shippingKeywords = [\
'shipped', 'tracking', 'delivery', 'dispatched',\
'courier', 'on the way', 'out for delivery'\
];

static const promotionKeywords = [\
'sale', 'discount', 'offer', 'coupon', 'deal',\
'%off', 'limited time', 'exclusive', 'promo'\
];

bool isEcommerceEmail(String sender, String subject, String body) {\
final lowerSender = sender.toLowerCase();\
final lowerSubject = subject.toLowerCase();\
final lowerBody = body.toLowerCase();

// Check if sender is from known e-commerce domain\
final isFromEcommerce = ecommerceDomains.any(\
`  `(domain) => lowerSender.contains(domain)\
);\
\
if (isFromEcommerce) return true;\
\
// Check for e-commerce keywords\
final allKeywords = [\
...orderKeywords,\
...shippingKeywords,\
...promotionKeywords,\
];\
\
final hasKeywords = allKeywords.any((keyword) =>\
`  `lowerSubject.contains(keyword) || lowerBody.contains(keyword)\
);\
\
return hasKeywords;

}

String categorizeEmail(String subject, String body) {\
final lowerSubject = subject.toLowerCase();\
final lowerBody = body.toLowerCase();

// Check order confirmation\
if (orderKeywords.any((kw) => \
`    `lowerSubject.contains(kw) || lowerBody.contains(kw))) {\
`  `return 'order';\
}\
\
// Check shipping\
if (shippingKeywords.any((kw) => \
`    `lowerSubject.contains(kw) || lowerBody.contains(kw))) {\
`  `return 'shipping';\
}\
\
// Check promotions\
if (promotionKeywords.any((kw) => \
`    `lowerSubject.contains(kw) || lowerBody.contains(kw))) {\
`  `return 'promotion';\
}\
\
return 'other';

}

EmailModel classifyEmail(EmailModel email) {\
final isEcommerce = isEcommerceEmail(\
email.sender,\
email.subject,\
email.body,\
);

final category = isEcommerce\
`    `? categorizeEmail(email.subject, email.body)\
`    `: 'other';\
\
return EmailModel(\
`  `id: email.id,\
`  `subject: email.subject,\
`  `sender: email.sender,\
`  `snippet: email.snippet,\
`  `date: email.date,\
`  `body: email.body,\
`  `isEcommerce: isEcommerce,\
`  `category: category,\
);

}\
}

<a name="option_2_hugging_face_model_advanced"></a>**Option 2: Hugging Face Model (Advanced)**

For more accurate classification, you can use pre-trained models from Hugging Face. Since we cannot use cloud APIs, we need to run models on-device.

<a name="model_selection_criteria"></a>**Model Selection Criteria**

1. Small model size (< 100MB for mobile)
1. Fast inference time (< 500ms per email)
1. Support for text classification
1. Available in TFLite or ONNX format

<a name="recommended_models"></a>**Recommended Models**

1. **DistilBERT-base-uncased** - Lightweight BERT variant
1. **MobileBERT** - Optimized for mobile devices
1. **TinyBERT** - Even smaller BERT variant

<a name="model_conversion_process"></a>**Model Conversion Process**

1. Download model from Hugging Face Hub
1. Convert to TFLite or ONNX format
1. Optimize for mobile (quantization)
1. Bundle with Flutter app
1. Load and run inference on-device

<a name="tflite_integration_example"></a>**TFLite Integration Example**

// pubspec.yaml\
dependencies:\
tflite\_flutter: ^0.10.0

// lib/services/ml\_classifier\_service.dart\
import 'package:tflite\_flutter/tflite\_flutter.dart';

class MLClassifierService {\
Interpreter? \_interpreter;

Future<void> loadModel() async {\
\_interpreter = await Interpreter.fromAsset(\
'assets/models/email\_classifier.tflite'\
);\
}

Future<bool> classifyEmail(String emailText) async {\
if (\_interpreter == null) {\
throw Exception('Model not loaded');\
}

// Tokenize and preprocess text\
final input = preprocessText(emailText);\
\
// Run inference\
final output = List.filled(1, 0).reshape([1, 1]);\
\_interpreter!.run(input, output);\
\
// Return true if e-commerce (threshold > 0.5)\
return output[0][0] > 0.5;

}

List<List<int>> preprocessText(String text) {\
// Implement tokenization logic\
// This is simplified - real implementation needs proper tokenizer\
return [[0]]; // Placeholder\
}\
}

**Note:** The ML approach requires significant setup. For a course project with limited Flutter experience, keyword-based classification is recommended.

-----
<a name="state_management_with_provider"></a>**State Management with Provider**

Provider is a popular state management solution in Flutter that makes it easy to manage app state and rebuild UI when data changes.

<a name="provider_setup"></a>**Provider Setup**

// pubspec.yaml\
dependencies:\
provider: ^6.1.0

// lib/providers/email\_provider.dart\
import 'package:flutter/foundation.dart';\
import '../models/email\_model.dart';\
import '../services/gmail\_service.dart';\
import '../services/classifier\_service.dart';

class EmailProvider extends ChangeNotifier {\
final GmailService \_gmailService;\
final ClassifierService \_classifierService;

List<EmailModel> \_emails = [];\
List<EmailModel> \_ecommerceEmails = [];\
bool \_isLoading = false;\
String \_selectedCategory = 'all';

List<EmailModel> get emails => \_emails;\
List<EmailModel> get ecommerceEmails => \_ecommerceEmails;\
bool get isLoading => \_isLoading;\
String get selectedCategory => \_selectedCategory;

EmailProvider(this.\_gmailService, this.\_classifierService);

Future<void> fetchAndClassifyEmails() async {\
\_isLoading = true;\
notifyListeners();

try {\
`  `// Fetch emails from Gmail API\
`  `final messages = await \_gmailService.fetchEmails(maxResults: 100);\
\
`  `// Convert to EmailModel\
`  `\_emails = messages\
.map((msg) => EmailModel.fromGmailMessage(msg))\
.toList();\
\
`  `// Classify emails\
`  `\_ecommerceEmails = \_emails\
.map((email) => \_classifierService.classifyEmail(email))\
.where((email) => email.isEcommerce)\
.toList();\
\
`  `\_isLoading = false;\
`  `notifyListeners();\
} catch (e) {\
`  `print('Error: $e');\
`  `\_isLoading = false;\
`  `notifyListeners();\
}

}

void setCategory(String category) {\
\_selectedCategory = category;\
notifyListeners();\
}

List<EmailModel> getFilteredEmails() {\
if (\_selectedCategory == 'all') {\
return \_ecommerceEmails;\
}\
return \_ecommerceEmails\
.where((email) => email.category == \_selectedCategory)\
.toList();\
}\
}

-----
<a name="user_interface_design"></a>**User Interface Design**

<a name="login_screen"></a>**Login Screen**

// lib/screens/login\_screen.dart\
import 'package:flutter/material.dart';\
import '../services/auth\_service.dart';

class LoginScreen extends StatelessWidget {\
final AuthService authService;

const LoginScreen({required this.authService});

@override\
Widget build(BuildContext context) {\
return Scaffold(\
body: Center(\
child: Column(\
mainAxisAlignment: MainAxisAlignment.center,\
children: [\
Icon(Icons.mail, size: 100, color: Colors.blue),\
SizedBox(height: 20),\
Text(\
'E-Commerce Email Organizer',\
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),\
),\
SizedBox(height: 40),\
ElevatedButton.icon(\
onPressed: () async {\
final account = await authService.signIn();\
if (account != null) {\
Navigator.pushReplacementNamed(context, '/dashboard');\
}\
},\
icon: Icon(Icons.login),\
label: Text('Sign in with Google'),\
style: ElevatedButton.styleFrom(\
padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),\
),\
),\
],\
),\
),\
);\
}\
}

<a name="dashboard_screen"></a>**Dashboard Screen**

// lib/screens/dashboard\_screen.dart\
import 'package:flutter/material.dart';\
import 'package:provider/provider.dart';\
import '../providers/email\_provider.dart';\
import '../widgets/email\_card.dart';\
import '../widgets/category\_filter.dart';

class DashboardScreen extends StatefulWidget {\
@override\
\_DashboardScreenState createState() => \_DashboardScreenState();\
}

class \
\
\
\
*DashboardScreenState extends State<DashboardScreen> {@overridevoid initState() {super.initState();WidgetsBinding.instance.addPostFrameCallback((*) {\
context.read<EmailProvider>().fetchAndClassifyEmails();\
});\
}

@override\
Widget build(BuildContext context) {\
return Scaffold(\
appBar: AppBar(\
title: Text('E-Commerce Emails'),\
actions: [\
IconButton(\
icon: Icon(Icons.refresh),\
onPressed: () {\
context.read<EmailProvider>().fetchAndClassifyEmails();\
},\
),\
],\
),\
body: Consumer<EmailProvider>(\
builder: (context, provider, child) {\
if (provider.isLoading) {\
return Center(child: CircularProgressIndicator());\
}

`      `return Column(\
`        `children: [\
`          `CategoryFilter(),\
`          `Expanded(\
`            `child: ListView.builder(\
`              `itemCount: provider.getFilteredEmails().length,\
`              `itemBuilder: (context, index) {\
`                `final email = provider.getFilteredEmails()[index];\
`                `return EmailCard(email: email);\
`              `},\
`            `),\
`          `),\
`        `],\
`      `);\
`    `},\
`  `),\
);

}\
}

<a name="email_card_widget"></a>**Email Card Widget**

// lib/widgets/email\_card.dart\
import 'package:flutter/material.dart';\
import '../models/email\_model.dart';

class EmailCard extends StatelessWidget {\
final EmailModel email;

const EmailCard({required this.email});

Color \_getCategoryColor(String category) {\
switch (category) {\
case 'order':\
return Colors.green;\
case 'shipping':\
return Colors.blue;\
case 'promotion':\
return Colors.orange;\
default:\
return Colors.grey;\
}\
}

@override\
Widget build(BuildContext context) {\
return Card(\
margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),\
child: ListTile(\
leading: CircleAvatar(\
backgroundColor: \_getCategoryColor(email.category),\
child: Icon(Icons.mail, color: Colors.white),\
),\
title: Text(\
email.subject,\
maxLines: 1,\
overflow: TextOverflow.ellipsis,\
),\
subtitle: Column(\
crossAxisAlignment: CrossAxisAlignment.start,\
children: [\
Text(email.sender, maxLines: 1),\
SizedBox(height: 4),\
Text(\
email.snippet,\
maxLines: 2,\
overflow: TextOverflow.ellipsis,\
style: TextStyle(fontSize: 12),\
),\
],\
),\
trailing: Chip(\
label: Text(\
email.category.toUpperCase(),\
style: TextStyle(fontSize: 10, color: Colors.white),\
),\
backgroundColor: \_getCategoryColor(email.category),\
),\
onTap: () {\
Navigator.pushNamed(\
context,\
'/email-detail',\
arguments: email,\
);\
},\
),\
);\
}\
}

<a name="category_filter_widget"></a>**Category Filter Widget**

// lib/widgets/category\_filter.dart\
import 'package:flutter/material.dart';\
import 'package:provider/provider.dart';\
import '../providers/email\_provider.dart';

class CategoryFilter extends StatelessWidget {\
final categories = ['all', 'order', 'shipping', 'promotion', 'other'];

@override\
Widget build(BuildContext context) {\
return Consumer<EmailProvider>(\
builder: (context, provider, child) {\
return Container(\
height: 50,\
child: ListView.builder(\
scrollDirection: Axis.horizontal,\
itemCount: categories.length,\
itemBuilder: (context, index) {\
final category = categories[index];\
final isSelected = provider.selectedCategory == category;

`          `return Padding(\
`            `padding: EdgeInsets.symmetric(horizontal: 5),\
`            `child: FilterChip(\
`              `label: Text(category.toUpperCase()),\
`              `selected: isSelected,\
`              `onSelected: (selected) {\
`                `provider.setCategory(category);\
`              `},\
`            `),\
`          `);\
`        `},\
`      `),\
`    `);\
`  `},\
);

}\
}

-----
<a name="data_persistence_and_caching"></a>**Data Persistence and Caching**

To improve performance and reduce API calls, implement local caching using SharedPreferences or Hive database.

<a name="cache_strategy"></a>**Cache Strategy**

1. Cache classified emails locally
1. Refresh cache every 30 minutes or on user request
1. Store only email metadata, not full body (privacy)
1. Clear cache on logout

<a name="sharedpreferences_implementation"></a>**SharedPreferences Implementation**

// lib/services/cache\_service.dart\
import 'dart:convert';\
import 'package:shared\_preferences/shared\_preferences.dart';\
import '../models/email\_model.dart';

class CacheService {\
static const String cacheKey = 'ecommerce\_emails\_cache';\
static const String timestampKey = 'cache\_timestamp';

Future<void> cacheEmails(List<EmailModel> emails) async {\
final prefs = await SharedPreferences.getInstance();\
final emailsJson = emails.map((e) => e.toJson()).toList();\
await prefs.setString(cacheKey, jsonEncode(emailsJson));\
await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);\
}

Future<List<EmailModel>?> getCachedEmails() async {\
final prefs = await SharedPreferences.getInstance();\
final timestamp = prefs.getInt(timestampKey) ?? 0;\
final now = DateTime.now().millisecondsSinceEpoch;

// Check if cache is older than 30 minutes\
if (now - timestamp > 30 \* 60 \* 1000) {\
`  `return null; // Cache expired\
}\
\
final cachedData = prefs.getString(cacheKey);\
if (cachedData == null) return null;\
\
final emailsJson = jsonDecode(cachedData) as List;\
return emailsJson.map((e) => EmailModel.fromJson(e)).toList();

}

Future<void> clearCache() async {\
final prefs = await SharedPreferences.getInstance();\
await prefs.remove(cacheKey);\
await prefs.remove(timestampKey);\
}\
}

-----
<a name="performance_optimization"></a>**Performance Optimization**

<a name="gmail_api_rate_limits"></a>**Gmail API Rate Limits**

Gmail API has the following quotas:

1. 1 billion quota units per day
1. users.messages.list: 5 quota units
1. users.messages.get: 5 quota units
1. Maximum 250 quota units per user per second

<a name="optimization_strategies"></a>**Optimization Strategies**

1. **Batch Requests** - Fetch multiple emails in single request
1. **Pagination** - Load emails incrementally
1. **Partial Responses** - Request only needed fields
1. **Local Caching** - Minimize redundant API calls
1. **Background Sync** - Update emails in background

<a name="pagination_implementation"></a>**Pagination Implementation**

class GmailService {\
String? \_nextPageToken;

Future<List<Message>> fetchNextPage() async {\
final response = await \_gmailApi!.users.messages.list(\
'me',\
maxResults: 50,\
pageToken: \_nextPageToken,\
);

\_nextPageToken = response.nextPageToken;\
\
// Fetch full messages...\
return messages;

}

bool hasMorePages() => \_nextPageToken != null;\
}

-----
<a name="testing_strategy"></a>**Testing Strategy**

<a name="unit_tests"></a>**Unit Tests**

Test individual components in isolation:

1. Classifier logic with known email samples
1. Email parsing from Gmail API response
1. Category assignment accuracy
1. Cache read/write operations

<a name="widget_tests"></a>**Widget Tests**

Test UI components:

1. Email card rendering
1. Category filter interaction
1. Dashboard state updates
1. Navigation flow

<a name="integration_tests"></a>**Integration Tests**

Test complete workflows:

1. OAuth login flow
1. Email fetching and classification
1. Dashboard refresh
1. Category filtering

<a name="sample_unit_test"></a>**Sample Unit Test**

// test/classifier\_service\_test.dart\
import 'package:flutter\_test/flutter\_test.dart';\
import 'package:ecommerce\_email\_organizer/services/classifier\_service.dart';

void main() {\
group('ClassifierService', () {\
final classifier = ClassifierService();

test('detects Amazon email as e-commerce', () {\
`  `final isEcommerce = classifier.isEcommerceEmail(\
`    `'no-reply@amazon.com',\
`    `'Your order has shipped',\
`    `'Track your package...',\
`  `);\
`  `expect(isEcommerce, true);\
});\
\
test('categorizes shipping email correctly', () {\
`  `final category = classifier.categorizeEmail(\
`    `'Your order has been dispatched',\
`    `'Tracking number: ABC123',\
`  `);\
`  `expect(category, 'shipping');\
});\
\
test('categorizes promotion email correctly', () {\
`  `final category = classifier.categorizeEmail(\
`    `'50% OFF Sale - Limited Time',\
`    `'Get exclusive discounts...',\
`  `);\
`  `expect(category, 'promotion');\
});

});\
}

-----
<a name="security_and_privacy_considerations"></a>**Security and Privacy Considerations**

<a name="data_security_best_practices"></a>**Data Security Best Practices**

1. Never store OAuth tokens in plain text
1. Use secure storage (flutter\_secure\_storage) for tokens
1. Request minimum necessary Gmail scopes
1. Process emails locally, avoid sending to external servers
1. Clear sensitive data on logout
1. Implement app lock (PIN/biometric)

<a name="privacy_first_design"></a>**Privacy-First Design**

1. Inform users about data access in consent screen
1. Process classification locally (no server upload)
1. Cache only metadata, not full email body
1. Provide option to clear all data
1. Comply with Google API Services User Data Policy

<a name="secure_token_storage"></a>**Secure Token Storage**

// pubspec.yaml\
dependencies:\
flutter\_secure\_storage: ^9.0.0

// lib/services/secure\_storage\_service.dart\
import 'package:flutter\_secure\_storage/flutter\_secure\_storage.dart';

class SecureStorageService {\
final \_storage = FlutterSecureStorage();

Future<void> saveAccessToken(String token) async {\
await \_storage.write(key: 'access\_token', value: token);\
}

Future<String?> getAccessToken() async {\
return await \_storage.read(key: 'access\_token');\
}

Future<void> clearTokens() async {\
await \_storage.deleteAll();\
}\
}

-----
<a name="deployment_checklist"></a>**Deployment Checklist**

<a name="pre_deployment_tasks"></a>**Pre-Deployment Tasks**

1. Complete OAuth consent screen configuration
1. Add privacy policy URL
1. Test on both Android and iOS devices
1. Verify Gmail API quotas and limits
1. Implement error handling for API failures
1. Add loading states for better UX
1. Test offline behavior
1. Optimize app size (remove unused packages)

<a name="android_build"></a>**Android Build**

<a name="build_apk_for_testing"></a>**Build APK for testing**

flutter build apk --release

<a name="build_app_bundle_for_play_store"></a>**Build App Bundle for Play Store**

flutter build appbundle --release

<a name="ios_build"></a>**iOS Build**

<a name="build_for_ios"></a>**Build for iOS**

flutter build ios --release

<a name="archive_in_xcode_for_app_store_su_d78a48"></a>**Archive in Xcode for App Store submission**

<a name="app_store_requirements"></a>**App Store Requirements**

1. Privacy policy explaining Gmail access
1. Screenshots showing email dashboard
1. App description mentioning e-commerce focus
1. Compliance with Google API Terms of Service
1. OAuth consent screen verification
-----
<a name="future_enhancements"></a>**Future Enhancements**

<a name="potential_features"></a>**Potential Features**

1. Search functionality within e-commerce emails
1. Email notifications for order updates
1. Integration with shipment tracking APIs
1. Spending analytics from order emails
1. Export emails to PDF or CSV
1. Multi-account support
1. Dark mode theme
1. Spam detection and filtering

<a name="advanced_classification"></a>**Advanced Classification**

1. Train custom model on user's email patterns
1. Sentiment analysis for product reviews
1. Extract structured data (order ID, tracking number)
1. Identify return windows and expiry dates
1. Price tracking from promotional emails
-----
<a name="troubleshooting_common_issues"></a>**Troubleshooting Common Issues**

<a name="gmail_api_authentication_errors"></a>**Gmail API Authentication Errors**

**Issue:** "Error 401: Invalid Credentials"

**Solution:**

1. Verify OAuth client ID configuration
1. Check if Gmail API is enabled in Google Cloud Console
1. Ensure scopes match between request and consent screen
1. Refresh access token if expired

<a name="email_fetching_issues"></a>**Email Fetching Issues**

**Issue:** "No emails returned from API"

**Solution:**

1. Check user has emails in Gmail account
1. Verify label IDs are correct
1. Increase maxResults parameter
1. Check for API quota exceeded errors

<a name="classification_accuracy_issues"></a>**Classification Accuracy Issues**

**Issue:** "Many false positives/negatives"

**Solution:**

1. Expand keyword lists with more variations
1. Add more e-commerce domains to detector
1. Implement scoring system instead of boolean match
1. Consider using ML model for better accuracy

<a name="flutter_build_errors"></a>**Flutter Build Errors**

**Issue:** "Gradle build failed" or "CocoaPods errors"

**Solution:**

1. Run flutter clean and flutter pub get
1. Update Android minSdkVersion to 21+
1. Run pod install in ios directory
1. Check Xcode version compatibility
-----
<a name="learning_resources"></a>**Learning Resources**

<a name="flutter_official_documentation"></a>**Flutter Official Documentation**

1. Flutter Documentation: <https://docs.flutter.dev/>
1. Dart Language Tour: <https://dart.dev/guides/language/language-tour>
1. Flutter Cookbook: <https://docs.flutter.dev/cookbook>
1. Widget Catalog: <https://docs.flutter.dev/ui/widgets>

<a name="gmail_api_resources"></a>**Gmail API Resources**

1. Gmail API Overview: <https://developers.google.com/gmail/api/guides>
1. API Reference: <https://developers.google.com/gmail/api/reference/rest>
1. OAuth 2.0 Guide: <https://developers.google.com/identity/protocols/oauth2>
1. Quota Information: <https://developers.google.com/gmail/api/reference/quota>

<a name="flutter_packages"></a>**Flutter Packages**

1. google\_sign\_in: <https://pub.dev/packages/google_sign_in>
1. googleapis: <https://pub.dev/packages/googleapis>
1. provider: <https://pub.dev/packages/provider>
1. shared\_preferences: <https://pub.dev/packages/shared_preferences>

<a name="video_tutorials"></a>**Video Tutorials**

1. Flutter official YouTube channel
1. "Flutter & Gmail API Integration" tutorials
1. "OAuth 2.0 in Flutter" guides
1. "Provider State Management" courses
-----
<a name="project_timeline_estimation"></a>**Project Timeline Estimation**

<a name="week_1_setup_and_authentication"></a>**Week 1: Setup and Authentication**

1. Install Flutter and setup development environment
1. Create project structure
1. Configure Google Cloud Console and OAuth
1. Implement Google Sign-In
1. Test authentication flow

<a name="week_2_gmail_integration"></a>**Week 2: Gmail Integration**

1. Implement Gmail API service
1. Create email model and parsing logic
1. Test email fetching with different filters
1. Implement pagination
1. Add error handling

<a name="week_3_classification_and_ui"></a>**Week 3: Classification and UI**

1. Implement keyword-based classifier
1. Create email provider for state management
1. Build dashboard UI
1. Implement email cards and category filters
1. Add loading states and empty states

<a name="week_4_testing_and_polish"></a>**Week 4: Testing and Polish**

1. Write unit tests for classifier
1. Test on physical devices
1. Implement caching for performance
1. Fix bugs and edge cases
1. Prepare documentation and demo
-----
<a name="conclusion"></a>**Conclusion**

This guide provides a complete roadmap for building an e-commerce email organizer app using Flutter. The project combines several important concepts:

1. Cross-platform mobile development with Flutter
1. OAuth 2.0 authentication with Google
1. Gmail API integration for email access
1. Email classification using keyword matching
1. State management with Provider
1. Local data caching for performance

For your course project, the keyword-based approach is recommended as it requires less ML expertise and infrastructure. Focus on creating a clean UI, reliable email fetching, and accurate classification based on common e-commerce patterns.

The modular architecture makes it easy to swap the classification method later if you want to experiment with Hugging Face models. Start with the MVP (Minimum Viable Product) using keywords, and enhance features iteratively.

Good luck with your Flutter development journey!

-----
<a name="appendix_a_complete_pubspec_yaml"></a>**Appendix A: Complete pubspec.yaml**

name: ecommerce\_email\_organizer\
description: An app to organize e-commerce emails from Gmail\
version: 1.0.0+1

environment:\
sdk: '>=3.0.0 <4.0.0'

dependencies:\
flutter:\
sdk: flutter

<a name="google_authentication"></a>**Google Authentication**

google\_sign\_in: ^7.2.0

<a name="gmail_api"></a>**Gmail API**

googleapis: ^16.0.0\
googleapis\_auth: ^1.6.0

<a name="http_client"></a>**HTTP Client**

http: ^1.2.0

<a name="state_management"></a>**State Management**

provider: ^6.1.0

<a name="local_storage"></a>**Local Storage**

shared\_preferences: ^2.2.0

<a name="secure_storage"></a>**Secure Storage**

flutter\_secure\_storage: ^9.0.0

<a name="environment_variables"></a>**Environment Variables**

flutter\_dotenv: ^5.1.0

<a name="ui_components"></a>**UI Components**

cupertino\_icons: ^1.0.6

dev\_dependencies:\
flutter\_test:\
sdk: flutter\
flutter\_lints: ^3.0.0

flutter:\
uses-material-design: true

assets:\
\- .env\
\- assets/models/ # For ML models if using

-----
<a name="appendix_b_sample_email_data_structure"></a>**Appendix B: Sample Email Data Structure**

{\
"id": "18abc123def456",\
"threadId": "18abc123def456",\
"labelIds": ["INBOX", "IMPORTANT"],\
"snippet": "Your order #12345 has been confirmed...",\
"payload": {\
"headers": [\
{"name": "From", "value": "<noreply@amazon.com>"},\
{"name": "Subject", "value": "Order Confirmation"},\
{"name": "Date", "value": "Mon, 2 Mar 2026 12:00:00 +0530"}\
],\
"body": {\
"size": 1234,\
"data": "VGhhbmsgeW91IGZvciB5b3VyIG9yZGVyIQ=="\
}\
},\
"internalDate": "1709366400000"\
}

-----
<a name="appendix_c_gmail_api_scopes_reference"></a>**Appendix C: Gmail API Scopes Reference**

|Scope|Permission Level|
| :- | :- |
|gmail.readonly|Read all resources and metadata|
|gmail.modify|Read, modify (excluding delete)|
|gmail.labels|Manage labels only|
|gmail.send|Send emails only|
|gmail.compose|Create drafts and send|

Table 3: Gmail API scope permissions

For this project, use gmail.readonly to minimize permission scope and improve user trust.
