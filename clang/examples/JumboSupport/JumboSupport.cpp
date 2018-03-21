//===- ResetAnonymousNamespace.cpp ----------------------------------------===//
//
// Clang plugin that adds
//
//   #pragma reset_anonymous_namespace
//
// which resets the anonymous namespace, as if a new translation unit was being
// processed.
//
//===----------------------------------------------------------------------===//

#include <set>
#include <string>

#include "clang/Frontend/FrontendPluginRegistry.h"
#include "clang/AST/AST.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Lex/Preprocessor.h"
#include "clang/Lex/LexDiagnostic.h"

namespace {

bool IsLocationInFile(clang::SourceManager &SM,
                      clang::SourceLocation Loc,
                      const clang::FileEntry *File) {
  clang::FileID FID = SM.getFileID(SM.getSpellingLoc(Loc));
  return FID.isValid() && SM.getFileEntryForID(FID) == File;
}

class DisableTaggedNamespaceDecls
    : public clang::RecursiveASTVisitor<DisableTaggedNamespaceDecls>
{
 private:
  clang::SourceManager &SM;
  const clang::FileEntry *File;

 public:
  DisableTaggedNamespaceDecls(clang::SourceManager &SM,
                              const clang::FileEntry *File)
      : SM(SM), File(File) {}

  bool VisitNamespaceDecl(clang::NamespaceDecl* NS) {
    if (NS->isAnonymousNamespace())
      if (IsLocationInFile(SM, NS->getLocStart(), File))
        NS->setDisabled();
    return true;
  }
};

class ASTConsumer : public clang::ASTConsumer {
  clang::ASTContext* Context;

public:
  static ASTConsumer *Instance;

  ASTConsumer() {
    Instance = this;
  }

  void Initialize(clang::ASTContext &Ctx) override {
    Context = &Ctx;
  }

  clang::ASTContext *getASTContext() { return Context; }
};

ASTConsumer *ASTConsumer::Instance = nullptr;

class PPCallbacks : public clang::PPCallbacks {
  clang::Preprocessor &PP;
  clang::SourceManager &SM;

  const clang::FileEntry *CurrentFile;

  std::set<std::string> DefinedMacros;

 public:
  PPCallbacks(clang::Preprocessor &PP)
      : PP(PP), SM(PP.getSourceManager()) {}

  static void Register(clang::Preprocessor &PP) {
    PP.addPPCallbacks(llvm::make_unique<PPCallbacks>(PP));
  }

  void InclusionDirective(clang::SourceLocation HashLoc,
                          const clang::Token&,
                          clang::StringRef,
                          bool,
                          clang::CharSourceRange,
                          const clang::FileEntry *File,
                          clang::StringRef,
                          clang::StringRef,
                          const clang::Module*) override {
    if (SM.isInMainFile(HashLoc))
      CurrentFile = File;
  }

  void FileChanged(clang::SourceLocation Loc,
                   FileChangeReason Reason,
                   clang::SrcMgr::CharacteristicKind,
                   clang::FileID PrevFID) override {
    if (SM.isInMainFile(Loc)) {
      auto Context = ASTConsumer::Instance->getASTContext();

      DisableTaggedNamespaceDecls Visitor(SM, CurrentFile);
      Visitor.TraverseDecl(Context->getTranslationUnitDecl());

      llvm::BumpPtrAllocator& Allocator = PP.getPreprocessorAllocator();
      for (auto Name : DefinedMacros) {
        clang::IdentifierInfo *II = PP.getIdentifierInfo(Name);
        PP.appendMacroDirective(II, new (Allocator) clang::UndefMacroDirective(Loc));
      }

      CurrentFile = nullptr;
      DefinedMacros.clear();
    }
  }

  void MacroDefined(const clang::Token &Name,
                    const clang::MacroDirective *MD) override {
    if (CurrentFile && IsLocationInFile(SM, Name.getLocation(), CurrentFile))
      DefinedMacros.emplace(Name.getIdentifierInfo()->getName().str());
  }

  void MacroUndefined(const clang::Token &Name,
                      const clang::MacroDefinition &MD,
                      const clang::MacroDirective *Undef) override {
    if (CurrentFile && IsLocationInFile(SM, Name.getLocation(), CurrentFile))
      DefinedMacros.erase(Name.getIdentifierInfo()->getName().str());
  }
};

class JumboFrontendAction : public clang::PluginASTAction {
public:
  std::unique_ptr<clang::ASTConsumer> CreateASTConsumer(
      clang::CompilerInstance &CI, llvm::StringRef) override {
    return llvm::make_unique<ASTConsumer>();
  }

  bool ParseArgs(const clang::CompilerInstance &CI,
                 const std::vector<std::string> &args) override {
    return true;
  }
};

class PragmaJumbo : public clang::PragmaHandler {
 public:
  PragmaJumbo() : clang::PragmaHandler("jumbo") { }

  void HandlePragma(clang::Preprocessor &PP,
                    clang::PragmaIntroducerKind Introducer,
                    clang::Token &PragmaTok) override {
    clang::Token Tok;
    PP.LexUnexpandedToken(Tok);
    if (Tok.isNot(clang::tok::eod))
      PP.Diag(Tok, clang::diag::ext_pp_extra_tokens_at_eol) << "pragma unity";

    if (!ASTConsumer::Instance) {
      // Plugin not enabled.
      return;
    }

    PPCallbacks::Register(PP);
  }
};

}

static clang::FrontendPluginRegistry::Add<JumboFrontendAction>
X("jumbo-support", "jumbo compilation support tools");

static clang::PragmaHandlerRegistry::Add<PragmaJumbo>
P1("jumbo", "begin treating top-level includes as jumbo includes");
