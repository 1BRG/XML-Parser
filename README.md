
# Custom Markup to XML Bidirectional Parser

This repository contains a pair of powerful Bash scripts designed for two-way conversion between standard XML and a simplified, human-readable custom markup format. This toolset is perfect for situations where you need the robustness of XML but prefer to write or generate data in a cleaner, bracket-based syntax.

The entire parsing and conversion logic is implemented in pure Bash, requiring no external dependencies or compilers.

## Key Features

-   **Bidirectional Conversion**: Seamlessly convert from the custom format to XML and back again.
-   **Pure Bash**: No dependencies needed. Runs on any system with a Bash-compatible shell (Linux, macOS, WSL for Windows).
-   **Robust Error Handling**: Both scripts perform syntax validation and report specific errors, including the line and character number where the error occurred.
-   **Readable Output**: The generated files are automatically indented to maintain a clean and hierarchical structure.
-   **Stack-Based Parsing**: Uses a stack to correctly handle nested tags and ensure the document is well-formed.

## The Custom Markup Format

The custom format uses tags, parentheses for attributes, and curly braces for content. It is designed to be intuitive and less verbose than XML.

### Syntax Rules:

-   **Tags**: A tag is defined by a name, followed by optional attributes in parentheses, and its content within curly braces.
    ```
    tag_name(attributes...) {
        content
    }
    ```
-   **Attributes**: Attributes are key-value pairs inside the parentheses, formatted as `key="value"`. Multiple attributes are separated by spaces.
    ```
    book(id="101" language="EN") { ... }
    ```
-   **Inner Text**: Text content is placed directly inside the curly braces.
    ```
    title() { The Lord of the Rings }
    ```
-   **Nesting**: Tags can be nested to create a hierarchy.
    ```
    root() {
        author(id="5") {
            firstName() { J.R.R. }
            lastName() { Tolkien }
        }
    }
    ```

---

## Usage

First, clone the repository and make the scripts executable:

```sh
git clone <your-repo-url>
cd <your-repo-name>
chmod +x parser-xml-format
chmod +x parser-format-xml-stefan
```

### 1. Converting Custom Format to XML

The `parser-xml-format` script reads a file written in the custom markup and converts it into a standard XML file.

**Command:**

```sh
./parser-xml-format <input_file.txt>
```

-   `<input_file.txt>`: Your file containing the custom markup.
-   The output will be automatically saved to a file named `output.xml`.

**Example:**

Given an `input.txt` file:

```
document() {
    user(id="1" active="true") {
        name() { Alice }
        role() { Admin }
    }
    user(id="2" active="false") {
        name() { Bob }
        role() { Guest }
    }
}
```

Running the script will produce `output.xml`:

```sh
./parser-xml-format input.txt
```

**Result (`output.xml`):**

```xml
<document>
   <user id="1" active="true">
      <name>
         Alice
      </name>
      <role>
         Admin
      </role>
   </user>
   <user id="2" active="false">
      <name>
         Bob
      </name>
      <role>
         Guest
      </role>
   </user>
</document>
```
*Note: The error messages in this script are in Romanian.*

### 2. Converting XML to Custom Format

The `parser-format-xml-stefan` script performs the reverse operation, converting a standard XML file into the custom markup format.

**Command:**

```sh
./parser-format-xml-stefan <input_file.xml> <output_file.txt>
```

-   `<input_file.xml>`: The source XML file.
-   `<output_file.txt>`: The destination file for the converted custom markup.

**Example:**

Using the `output.xml` generated in the previous step:

```sh
./parser-format-xml-stefan output.xml new_format.txt
```

**Result (`new_format.txt`):**

```
document(){
   user(id="1" active="true"){
      name(){
         Alice
      }
      role(){
         Admin
      }
   }
   user(id="2" active="false"){
      name(){
         Bob
      }
      role(){
         Guest
      }
   }
}
```

## Error Handling

The scripts are designed to catch common formatting errors and provide useful feedback. If the input file is malformed, the script will exit and print an error message indicating the problem and its location.

**Example Errors:**
-   Mismatched closing tags.
-   Missing brackets, parentheses, or quotes.
-   Tags opened in an invalid context.
-   Too many closing tags.
