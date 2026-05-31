# Vestiaire — Figma Design Specification
## Complete UI/UX Design Guide for Smart Wardrobe App

---

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Design System](#design-system)
3. [Screen Inventory](#screen-inventory)
4. [Component Library](#component-library)
5. [Image & Media Assets](#image--media-assets)
6. [Video Requirements](#video-requirements)
7. [User Flows](#user-flows)
8. [Figma File Structure](#figma-file-structure)

---

## Design Philosophy

### Core Principles
- **Calming & Intentional**: Use soft colors, generous whitespace, and smooth transitions
- **Supportive & Personal**: Design feels like a helpful companion, not demanding
- **Visual & Tactile**: Clothing items should feel tangible and organized
- **Weather-Aware**: Weather integration should feel natural and informative
- **Minimal Friction**: Reduce decision fatigue through clear hierarchy and smart defaults

### Mood & Aesthetic
- Clean, modern minimalism
- Warm neutrals with soft accent colors
- Photography-focused (user's clothing items are the hero)
- Inspired by: Notion, Things 3, Spotify (clean data presentation)

---


## Design System

### Color Palette

#### Primary Colors
```
Background:
- Primary BG: #FAFAFA (Off-white)
- Secondary BG: #FFFFFF (Pure white)
- Card BG: #F5F5F5 (Light gray)

Text:
- Primary Text: #1A1A1A (Near black)
- Secondary Text: #6B6B6B (Medium gray)
- Tertiary Text: #A0A0A0 (Light gray)

Accent Colors:
- Primary Accent: #8B7355 (Warm taupe/brown — grounding, wardrobe feel)
- Secondary Accent: #D4C5B9 (Light beige)
- Success: #7FA96F (Muted sage green)
- Warning: #E8A87C (Warm amber)
- Error: #C77A7A (Muted red)
```

#### Weather-Based Color Coding
```
Cold (< 50°F): #6B9AC4 (Cool blue)
Cool (50-60°F): #89B5D9 (Light blue)
Mild (60-70°F): #95C7A8 (Sage green)
Warm (70-80°F): #F4C87E (Warm yellow)
Hot (> 80°F): #E89A6F (Warm orange/coral)
```


### Typography

```
Primary Font: SF Pro (iOS native) / Inter (cross-platform alternative)

Hierarchy:
- Display: 32px, Bold (Page titles)
- H1: 28px, Semibold (Section headers)
- H2: 24px, Semibold (Subsections)
- H3: 20px, Medium (Card titles)
- Body Large: 17px, Regular (Primary content)
- Body: 15px, Regular (Secondary content)
- Caption: 13px, Regular (Metadata, labels)
- Small: 11px, Medium (Tags, badges)

Line Height: 1.4-1.6 for readability
Letter Spacing: -0.5% for large text, 0% for body
```

### Spacing System
```
Base Unit: 4px

Scale:
- 4px (XXS)
- 8px (XS)
- 12px (S)
- 16px (M)
- 24px (L)
- 32px (XL)
- 48px (XXL)
- 64px (XXXL)
```

### Border Radius
```
- Small cards/buttons: 8px
- Medium cards: 12px
- Large cards: 16px
- Circular avatars: 50%
```

---


## Screen Inventory

### 1. Onboarding & Authentication

#### 1.1 Splash Screen
- App logo with subtle animation
- Tagline: "Your Personal Wardrobe Companion"
- Clean, minimal background

#### 1.2 Welcome Screen
- Hero image/illustration showing organized wardrobe
- 3-4 key value propositions with icons
- "Get Started" CTA button

#### 1.3 Account Setup
- Name input
- Email/password or Apple Sign-In
- Optional: Profile photo upload
- Temperature preference toggle (Runs cold / Neutral / Runs hot)

#### 1.4 Permission Requests
- Location access (for weather)
- Calendar access (for outfit planning)
- Photo library access (for clothing uploads)
- Clear explanations for each permission

#### 1.5 Quick Start Tutorial
- 3-5 swipeable cards explaining core features
- Skip option available
- Visual examples of wardrobe organization

---


### 2. Main Navigation

#### 2.1 Tab Bar Navigation (Bottom)
```
Tabs:
1. Home (house icon)
2. Wardrobe (hanger icon)
3. Calendar (calendar icon)
4. Insights (bar chart icon)
5. Profile (person icon)
```

#### 2.2 Top Navigation Bar
- App logo/wordmark (left)
- Search icon (right)
- Notification bell icon (right)
- Context-aware title for current section

---

### 3. Home Screen

#### 3.1 Today View (Main Home)
**Components:**
- Weather card (prominent, top)
  - Current temperature + "Feels like" temp
  - Weather icon (animated)
  - Location name
  - High/Low for the day
  - Comfort recommendation: "Dress warm" / "Layer up" / "Light clothing"
  
- Today's Outfit Card
  - If planned: Display outfit preview (grid of items)
  - If not planned: "What will you wear today?" CTA
  - Quick edit button
  
- Suggested Items Section
  - 3-4 clothing items appropriate for today's weather
  - Based on temperature + user preferences
  - Tap to add to today's outfit
  
- Quick Actions
  - "Add new item" button
  - "Plan tomorrow" button
  - "Browse wardrobe" button


#### 3.2 Weather Detail Modal
- Hourly forecast (scrollable)
- 7-day forecast
- Precipitation probability
- Wind speed
- UV index
- Clothing recommendations per time of day

---

### 4. Wardrobe Section

#### 4.1 Wardrobe Overview
**Layout Options:**
- Grid view (default): 2-3 columns of clothing item cards
- List view: Item name, category, last worn date
- Filter bar at top

**Filter Options:**
- All Items
- Category tabs: Tops, Bottoms, Outerwear, Shoes, Accessories
- Season: Spring, Summer, Fall, Winter
- Color selector (color chips)
- Sort by: Recently added, Most worn, Least worn, Price

**Item Cards (Grid View):**
- Square photo of clothing item (clean background)
- Item name (below)
- Small category tag
- Favorite star icon (top right)

#### 4.2 Add New Item Screen
**Photo Upload:**
- Camera button (take photo)
- Gallery button (upload from library)
- AI background removal option
- Crop & rotate tools

**Item Details Form:**
- Item name (required)
- Category dropdown (required)
- Subcategory (e.g., T-shirt, Jeans)
- Brand
- Color picker + color tags
- Season checkboxes (multi-select)
- Fabric/material
- Purchase price (optional)
- Purchase date
- Notes field
- Save button


#### 4.3 Item Detail View
**Header:**
- Large photo of item (zoomable)
- Left/right arrows if multiple photos
- Edit button (top right)
- Delete button (top right menu)
- Favorite toggle

**Details Section:**
- All item metadata displayed
- "Times worn" counter with badge
- "Last worn" date
- Cost per wear calculation (highlighted if impressive)
- Purchase info

**Action Buttons:**
- "Add to outfit" button (primary)
- "Mark as worn today" button
- "Find similar items" (shopping link)

**Related Outfits:**
- Horizontal scroll of outfits containing this item
- Tap to view outfit details

---

### 5. Outfit Planning

#### 5.1 Create Outfit Screen
**Layout:**
- Outfit canvas (center) — drop zones for:
  - Top
  - Bottom
  - Outerwear (optional)
  - Shoes
  - Accessories (optional)
  
**Bottom Sheet:**
- Scrollable wardrobe items filtered by category
- Quick category tabs
- Search bar
- Drag and drop or tap to add

**Outfit Details:**
- Outfit name field
- Occasion tags (Casual, Work, Formal, Workout, etc.)
- Season tags
- Temperature range slider
- Notes field
- Save button


#### 5.2 Saved Outfits Gallery
- Grid view of complete outfits
- Each outfit card shows:
  - Composite image of all items
  - Outfit name
  - Occasion tag
  - "Times worn" counter
  - Last worn date
  
**Filter Options:**
- By occasion
- By season
- By temperature range
- Favorites only

#### 5.3 Outfit Detail View
- Full outfit displayed (all items visible)
- Outfit metadata
- Weather suitability indicator
- Edit button
- "Wear today" button (adds to calendar)
- "Duplicate & modify" button
- Individual item details (tap each item)

---

### 6. Calendar Integration

#### 6.1 Calendar View
**Month View:**
- Traditional calendar grid
- Each day shows mini outfit preview (if planned)
- Color coding by weather (background tint)
- Current day highlighted
- Tap day to see/edit outfit

**Week View:**
- Horizontal scrollable week
- Larger outfit previews
- Weather icon + temp for each day
- Swipe to plan outfit

**Day Detail:**
- Selected date (large header)
- Weather forecast for that day
- Currently planned outfit (large)
- "Change outfit" button
- "Mark as worn" button (for past dates)
- Alternative suggestions based on weather


#### 6.2 Quick Plan Modal
- Shows next 7 days
- For each day:
  - Weather preview
  - Drag outfit from saved outfits OR create new
  - Auto-suggestions based on weather
- Batch save button

---

### 7. Insights & Analytics

#### 7.1 Insights Dashboard
**Overview Cards:**
- Total wardrobe value
- Total items count
- Average cost per wear
- Most worn category

**Detailed Sections:**

**Most Worn Items:**
- Top 10 list with photos
- Wear count for each
- Cost per wear

**Least Worn Items:**
- Items worn 0-2 times
- Consideration prompts: "Maybe donate?"
- Days since last worn

**Category Breakdown:**
- Pie chart or bar chart
- Items per category
- Usage frequency per category

**Seasonal Analysis:**
- Items tagged per season
- Seasonal wear patterns
- Gap analysis (e.g., "You have few winter items")

**Color Analysis:**
- Color palette visualization
- Most worn colors
- Least worn colors
- Outfit color combination patterns

**Value Analysis:**
- Total spent on wardrobe
- Average item cost
- Best value items (low cost per wear)
- High cost, low wear items


#### 7.2 Individual Item Statistics
- Accessible from item detail view
- Wear history timeline
- Outfit associations
- Cost per wear over time (graph)

---

### 8. Profile & Settings

#### 8.1 Profile Screen
**Header:**
- Profile photo (editable)
- Name
- Member since date
- Wardrobe stats summary

**Sections:**
- My Preferences
- Temperature Sensitivity Settings
- Notifications
- Shopping Integration
- About & Support
- Log Out

#### 8.2 Preferences
- Default location
- Temperature unit (F/C)
- Measurement unit (US/Metric)
- Default calendar view
- Theme (Light/Dark/Auto)

#### 8.3 Temperature Sensitivity Settings
- Slider or options:
  - "I run cold" (suggest warmer outfits)
  - "I'm neutral"
  - "I run hot" (suggest cooler outfits)
- Custom temperature thresholds
- "Feels like" importance weight

#### 8.4 Notifications Settings
- Daily outfit reminders
- Weather alerts
- Outfit suggestion notifications
- Shopping deal alerts (if enabled)


#### 8.5 Shopping Integration Settings
- Toggle shopping features on/off
- Preferred retailers
- Budget alerts
- Replacement suggestions

---

### 9. Search & Discovery

#### 9.1 Global Search Screen
**Search Bar:**
- Placeholder: "Search items, outfits, or brands..."
- Voice search icon
- Cancel button

**Recent Searches:**
- Last 5-10 searches
- Clear all button

**Quick Filters:**
- Category chips
- Color filters
- Season filters

**Search Results:**
- Tabbed results:
  - Items
  - Outfits
  - Insights
- Relevant results with highlighting
- Sort options

#### 9.2 Advanced Filters Modal
- Multiple category selection
- Color palette selector (multi-select)
- Season multi-select
- Price range slider
- Brand search
- Usage frequency filter
- Date added range
- Favorites toggle


---

### 10. Shopping Features

#### 10.1 Shopping Discovery
- "Find Similar" results
- External retailer links
- Comparison tool (price, brand, reviews)
- "Add to wishlist" option

#### 10.2 Wishlist
- Items user wants to purchase
- Priority ranking
- Price tracking
- "Already own similar?" suggestions

---

### 11. Additional Screens

#### 11.1 Empty States
- Empty wardrobe: "Add your first item"
- No outfits: "Create your first outfit"
- No calendar plans: "Plan your week"
- No search results: Helpful suggestions

#### 11.2 Loading States
- Skeleton screens for data loading
- Smooth animations
- Progress indicators

#### 11.3 Error States
- Network error messages
- Permission denied messages
- Data sync failures
- Friendly illustrations + retry buttons

#### 11.4 Success Confirmations
- Item added successfully
- Outfit saved
- Calendar updated
- Toast notifications with checkmarks

---


## Component Library

### Reusable Components to Design

#### Buttons
1. **Primary Button**
   - Filled, accent color background
   - White text
   - 48px height
   - Border radius: 12px
   - States: Default, Pressed, Disabled

2. **Secondary Button**
   - Outlined, accent color border
   - Accent color text
   - Same dimensions as primary

3. **Text Button**
   - No background
   - Accent color text
   - Underline on hover

4. **Icon Button**
   - Circular or square
   - 44x44px minimum (touch target)
   - States: Default, Pressed, Disabled

#### Cards
1. **Item Card** (Wardrobe grid)
   - Square aspect ratio
   - Image with subtle shadow
   - Text overlay at bottom
   - Favorite icon (top right)

2. **Outfit Card**
   - Rectangular
   - Composite image preview
   - Metadata below
   - Action icons

3. **Weather Card**
   - Prominent on home screen
   - Gradient background (weather-appropriate)
   - Large temperature display
   - Icon + description


4. **Stat Card** (Insights)
   - White background
   - Large number/metric
   - Label below
   - Optional icon or trend indicator

#### Input Fields
1. **Text Input**
   - Label above
   - 48px height
   - Border radius: 8px
   - States: Empty, Focus, Filled, Error

2. **Search Bar**
   - Rounded pill shape
   - Search icon (left)
   - Clear button (right, when filled)
   - Light gray background

3. **Dropdown/Select**
   - Chevron down icon
   - Options modal or menu
   - Selected state styling

4. **Color Picker**
   - Color chips grid
   - Multi-select capability
   - Selected state with checkmark

5. **Date Picker**
   - Calendar modal
   - iOS native style
   - Range selection support

#### Navigation
1. **Tab Bar**
   - 5 tabs with icons
   - Active state: accent color + label
   - Inactive state: gray
   - Badge support for notifications

2. **Top Nav Bar**
   - 56px height
   - Title (centered or left-aligned)
   - Action buttons (right)
   - Back button (left)


#### Lists
1. **Item List Row**
   - Thumbnail (left)
   - Item name + metadata (center)
   - Chevron or action button (right)
   - 72px height

2. **Outfit List Row**
   - Outfit thumbnail (left)
   - Name + details (center)
   - Last worn date + wear count (right)

#### Modals & Sheets
1. **Bottom Sheet**
   - Handle bar at top
   - Draggable
   - Multiple heights: Peek, Half, Full
   - Blur background overlay

2. **Full Screen Modal**
   - Close button (top right)
   - Title (top center)
   - Content area
   - Primary action (bottom)

3. **Alert Dialog**
   - Title + message
   - 1-2 action buttons
   - Dismissible

#### Badges & Tags
1. **Category Tag**
   - Small, rounded pill
   - Category color + name
   - 24px height

2. **Season Badge**
   - Icon + text
   - Colored background

3. **Notification Badge**
   - Red circle with count
   - 16-20px diameter


#### Progress Indicators
1. **Loading Spinner**
   - Circular, animated
   - Accent color

2. **Progress Bar**
   - For multi-step processes
   - Step indicators

3. **Skeleton Loader**
   - Gray placeholder boxes
   - Shimmer animation

#### Icons
**Required Custom Icons:**
- Hanger (wardrobe)
- Outfit mannequin
- Temperature gauge
- Layers (outfit layering)
- Calendar with outfit
- Cost per wear badge
- Weather conditions (sun, cloud, rain, snow, etc.)
- Clothing categories (shirt, pants, shoe, jacket, accessory)

**Use SF Symbols for iOS:**
- Standard UI icons (search, settings, profile, etc.)

---


## Image & Media Assets

### High-Quality Image Requirements

#### 1. Clothing Item Photography
**Style Guidelines:**
- Clean, white or neutral background
- Good lighting (soft, diffused)
- Item centered and full-frame
- Flat lay or hanging presentation
- Consistent perspective across items
- High resolution: 1200x1200px minimum
- Format: PNG with transparency or JPG

**Example Categories to Photograph:**
- 5-10 tops (t-shirts, blouses, sweaters)
- 5-10 bottoms (jeans, pants, skirts)
- 3-5 outerwear pieces (jackets, coats)
- 5-8 shoes (sneakers, boots, sandals, heels)
- 5-8 accessories (bags, scarves, hats, jewelry)

**Optional Enhancements:**
- 360° views for key items
- Detail shots (fabric texture, tags, unique features)
- Multiple color variations of same style

#### 2. Outfit Compositions
**Requirements:**
- Complete outfits laid out flat (top, bottom, shoes)
- Consistent styling across all outfit mockups
- 10-15 different outfit combinations
- Mix of casual, work, and formal looks
- Seasonal variety


#### 3. Lifestyle & Marketing Images
**For Onboarding & Marketing:**
- Hero image: Person organizing closet or getting dressed
- Weather awareness: Person checking phone outdoors
- Outfit planning: Person with calendar or planning outfits
- Analytics: Person reviewing wardrobe insights
- Size: 1920x1080px (landscape) or 1080x1920px (portrait)
- Style: Bright, natural, aspirational but relatable

#### 4. UI Illustrations
**Custom Illustrations Needed:**
- Empty state illustrations (8-10 unique)
  - Empty wardrobe
  - Empty calendar
  - No search results
  - No internet connection
  - Permission required states
  
- Onboarding illustrations (3-5 slides)
  - Digital wardrobe concept
  - Weather integration
  - Outfit planning
  - Analytics insights

**Style:**
- Minimal, line-art style
- Warm color palette
- 512x512px
- SVG format preferred

#### 5. Icon Set
- 50-80 custom icons
- Line style, 2px stroke
- 24x24px artboard
- SVG format
- Icons for:
  - All clothing categories
  - Weather conditions
  - Seasons
  - UI actions
  - Analytics metrics


#### 6. Background Patterns & Textures
- Subtle fabric textures (for cards or backgrounds)
- Weather-themed subtle patterns
- 2-3 variations
- Tileable
- Low opacity overlays

#### 7. Profile & Avatar Placeholders
- Default avatar illustrations
- 3-5 style options
- Gender-neutral
- 256x256px

---


## Video Requirements

### 1. App Demo Videos

#### 1.1 Full App Walkthrough
**Duration:** 90-120 seconds
**Content:**
- Opening splash screen
- Quick onboarding flow
- Adding items to wardrobe
- Creating an outfit
- Planning on calendar
- Viewing insights
- Weather-based suggestion

**Specs:**
- Resolution: 1080x1920px (portrait, mobile)
- Frame rate: 60fps
- Format: MP4 (H.264)
- Include device frame (iPhone mockup)
- Smooth transitions between scenes

#### 1.2 Feature-Specific Videos (15-30 seconds each)

**Video 1: Adding Clothing Items**
- Opening camera
- Taking photo
- Adding details
- Saving to wardrobe

**Video 2: Creating Outfits**
- Browsing wardrobe
- Drag-and-drop items
- Naming outfit
- Saving

**Video 3: Weather Integration**
- Home screen with weather card
- Viewing "feels like" temp
- Getting outfit suggestion
- Adding to calendar


**Video 4: Calendar Planning**
- Opening calendar view
- Selecting date
- Choosing outfit
- Viewing week view

**Video 5: Analytics Dashboard**
- Scrolling through insights
- Tapping on most worn items
- Viewing cost per wear
- Category breakdown

#### 1.3 Microinteractions & Animations

**Required Animated Elements:**
- Splash screen logo reveal (2-3 sec)
- Tab switching animation
- Card flip/reveal
- Pull-to-refresh
- Item deletion swipe
- Success checkmark animation
- Loading spinners
- Skeleton screen shimmer
- Weather icon animations (sun rays, rain drops, etc.)
- Drag-and-drop feedback
- Button press states
- Modal appear/disappear
- Toast notification slide-in

**Specs:**
- 2-5 seconds each
- 60fps
- Loopable where appropriate
- Export as MP4 or Lottie JSON


### 2. Marketing Videos

#### 2.1 Social Media Teasers (15-30 sec)
**Instagram/TikTok Format:**
- Vertical 1080x1920px
- Fast-paced cuts
- Text overlays highlighting key features
- Upbeat background music
- Clear CTA at end

**Content Ideas:**
- "Stop stressing about what to wear"
- "Weather changes? We've got you covered"
- "See how much value you're getting from your wardrobe"
- Before/after: cluttered closet vs organized digital wardrobe

#### 2.2 App Store Preview Video
**Duration:** 30 seconds max
**Resolution:** 1080x1920px (portrait)
**Content:**
- Quick feature highlights
- Real app screens (not animated mockups)
- Minimal text, show don't tell
- App icon at end

---


## User Flows

### Key User Journeys to Map

#### 1. First-Time User Onboarding
```
Splash → Welcome → Sign Up → Permissions → Tutorial → Home (Empty State)
```

#### 2. Adding First Clothing Item
```
Home → Wardrobe → Add Item → Camera/Gallery → Photo Edit → Details Form → Save → Wardrobe (Item visible)
```

#### 3. Creating & Planning an Outfit
```
Home/Wardrobe → Create Outfit → Select Items → Name Outfit → Save → Calendar → Select Date → Assign Outfit
```

#### 4. Morning Routine Flow
```
Home → Check Weather → View Today's Outfit → (Optional: Change/Edit) → Mark as Worn
```

#### 5. Discovering Insights
```
Insights Tab → Overview Dashboard → Tap on "Most Worn" → Item Detail → View Related Outfits
```

#### 6. Shopping Integration
```
Item Detail → "Find Similar" → External Retailer Links → (Return to app)
```

#### 7. Search & Filter
```
Search Icon → Enter Query → View Results → Apply Filters → Select Item → Item Detail
```

---


## Figma File Structure

### Recommended Organization

```
📁 Vestiaire App Design
│
├── 📄 Cover Page
│   ├── App logo
│   ├── Project overview
│   └── Design team credits
│
├── 📄 Design System
│   ├── Colors (Styles + swatches)
│   ├── Typography (Text styles)
│   ├── Spacing Grid
│   ├── Border Radius values
│   ├── Elevation/Shadow styles
│   └── Icon library
│
├── 📄 Components
│   ├── Buttons (All variants)
│   ├── Input Fields
│   ├── Cards
│   ├── Navigation (Tab bar, top bar)
│   ├── Lists & Rows
│   ├── Modals & Sheets
│   ├── Badges & Tags
│   ├── Progress Indicators
│   └── Empty States
│
├── 📄 Icons
│   ├── UI Icons
│   ├── Clothing Category Icons
│   ├── Weather Icons
│   └── Season Icons
│
├── 📄 Illustrations
│   ├── Onboarding illustrations
│   ├── Empty state illustrations
│   └── Error state illustrations
│
├── 📄 Screens - Onboarding
│   ├── Splash Screen
│   ├── Welcome
│   ├── Sign Up/Login
│   ├── Permissions
│   └── Tutorial
```


```
├── 📄 Screens - Home
│   ├── Today View
│   ├── Weather Detail Modal
│   └── Quick Actions
│
├── 📄 Screens - Wardrobe
│   ├── Wardrobe Overview (Grid)
│   ├── Wardrobe Overview (List)
│   ├── Add New Item
│   ├── Item Detail
│   ├── Edit Item
│   └── Filter Views
│
├── 📄 Screens - Outfits
│   ├── Create Outfit
│   ├── Saved Outfits Gallery
│   ├── Outfit Detail
│   └── Edit Outfit
│
├── 📄 Screens - Calendar
│   ├── Month View
│   ├── Week View
│   ├── Day Detail
│   └── Quick Plan Modal
│
├── 📄 Screens - Insights
│   ├── Dashboard Overview
│   ├── Most/Least Worn
│   ├── Category Breakdown
│   ├── Seasonal Analysis
│   ├── Color Analysis
│   └── Value Analysis
│
├── 📄 Screens - Profile & Settings
│   ├── Profile Overview
│   ├── Preferences
│   ├── Temperature Settings
│   ├── Notifications
│   └── Shopping Integration
│
├── 📄 Screens - Search
│   ├── Search Home
│   ├── Search Results
│   └── Advanced Filters
```


```
├── 📄 Screens - Shopping
│   ├── Shopping Discovery
│   └── Wishlist
│
├── 📄 User Flows
│   ├── Onboarding Flow
│   ├── Add Item Flow
│   ├── Create Outfit Flow
│   ├── Morning Routine Flow
│   └── Other key journeys
│
├── 📄 Prototypes
│   ├── Interactive prototype links
│   └── Recorded prototype videos
│
└── 📄 Assets for Export
    ├── App Icon (all sizes)
    ├── App Store Screenshots
    └── Marketing Materials
```

### Figma Best Practices

1. **Use Auto Layout extensively** for responsive designs
2. **Create Component Variants** for different states (default, hover, pressed, disabled)
3. **Use Styles** for colors, text, and effects (consistent across all screens)
4. **Name layers clearly** (e.g., "Button/Primary/Default")
5. **Organize with Frames** (group related screens)
6. **Use Constraints** for responsive behavior
7. **Create Interactive Prototypes** for key flows
8. **Add Annotations** explaining interactions and logic
9. **Version Control** using Figma's branching feature for iterations

---


## Additional Design Considerations

### Accessibility

1. **Color Contrast**
   - Ensure WCAG AA compliance (4.5:1 for text)
   - Don't rely solely on color to convey information

2. **Touch Targets**
   - Minimum 44x44px for all interactive elements
   - Adequate spacing between buttons

3. **Text Legibility**
   - Minimum 15px for body text
   - Support Dynamic Type (iOS)

4. **Alternative Text**
   - Design for screen reader support
   - Label all icons and images

5. **Motion**
   - Respect "Reduce Motion" settings
   - Provide alternatives to animations

### Dark Mode Support

Design both light and dark mode versions:

**Dark Mode Palette:**
- Background: #121212
- Surface: #1E1E1E
- Card: #2C2C2C
- Text Primary: #FFFFFF
- Text Secondary: #B0B0B0
- Accent: Adjust to #A68B73 (slightly lighter)

### Responsive Design

While primarily mobile-focused, consider:
- iPhone SE (small)
- iPhone 14/15 Pro (standard)
- iPhone 14/15 Pro Max (large)
- iPad (tablet view - optional future enhancement)


---

## Quick Start Checklist for Figma Designer

### Phase 1: Foundation (Week 1)
- [ ] Set up Figma file structure
- [ ] Create design system (colors, typography, spacing)
- [ ] Design core components (buttons, inputs, cards)
- [ ] Design custom icon set
- [ ] Create base screen templates

### Phase 2: Core Screens (Week 2-3)
- [ ] Design onboarding flow (5-6 screens)
- [ ] Design home screen + weather integration
- [ ] Design wardrobe screens (overview, add item, item detail)
- [ ] Design outfit creation screens
- [ ] Design tab bar navigation

### Phase 3: Secondary Features (Week 3-4)
- [ ] Design calendar views
- [ ] Design insights dashboard
- [ ] Design profile & settings
- [ ] Design search & filter screens
- [ ] Design empty/error/loading states

### Phase 4: Polish & Assets (Week 4-5)
- [ ] Create all illustrations
- [ ] Design dark mode variants
- [ ] Create interactive prototypes
- [ ] Gather/create clothing item photos
- [ ] Design app icon and marketing assets
- [ ] Record demo videos

### Phase 5: Documentation (Week 5)
- [ ] Create design handoff notes for developers
- [ ] Document component usage
- [ ] Export all assets
- [ ] Create style guide PDF
- [ ] Final review and adjustments

---


## Resources & Inspiration

### Design Inspiration Sources

**Similar Apps to Study:**
- Whering (wardrobe organization)
- Stylebook (closet management)
- Combyne (outfit planning)
- Good On You (sustainable fashion)
- YNAB (for data visualization style)
- Things 3 (for clean UI patterns)

**Design Systems to Reference:**
- Apple Human Interface Guidelines
- Material Design (for component patterns)
- Shopify Polaris (for e-commerce patterns)

### Stock Photo Resources

For high-quality clothing photography:
- Unsplash (free, high-quality)
- Pexels (free stock photos)
- Freepik (illustrations and photos)
- Custom photoshoot recommended for final assets

### Icon Resources

- SF Symbols (free iOS icons)
- Feather Icons (clean, minimal)
- Heroicons (Tailwind's icon set)
- Iconoir (open source)
- Custom icon design for unique clothing categories

### Video & Animation

- Lottie Files (free animations)
- After Effects for custom animations
- ProtoPie or Principle for interactive prototypes
- Screen recording with QuickTime or iOS Simulator

---


## Export Specifications

### For Development Handoff

#### iOS Assets
- **App Icon**: Export at all required sizes (1024x1024 for App Store, plus all iOS sizes)
- **Screen Designs**: Export as PDF or PNG at @2x and @3x resolutions
- **Icons**: Export as PDF (vector) or PNG @2x, @3x
- **Images**: Export as PNG or JPG, optimize for performance
- **Animations**: Export as Lottie JSON or GIF

#### Naming Conventions
```
ic_clothing_type_top.png
img_onboarding_welcome.png
bg_weather_gradient.png
btn_primary_default.png
```

#### Color Codes
Export as:
- HEX codes for developers
- UIColor/Color extensions for SwiftUI
- RGB values where needed

#### Typography
Export as:
- Font names and sizes
- SwiftUI Text Style definitions
- Line height and letter spacing values

---

## Final Notes

This specification covers all major screens, components, and assets needed for Vestiaire. The design should feel:

✨ **Calming and supportive** — not overwhelming
👗 **Visually rich** — celebrating clothing as visual objects
🌤️ **Contextually aware** — weather feels integrated, not tacked on
📊 **Insightful** — data feels useful, not just decorative
💫 **Delightful** — small moments of joy in interactions

**Total Estimated Screens:** 50-60 unique screens
**Total Components:** 30-40 reusable components
**Timeline:** 4-6 weeks for comprehensive design system + all screens

Good luck with your Figma design! 🎨
