import SwiftUI
import BottomSheets

struct ExampleView: View {
    
    var body: some View {
        TabView {
            tab1
            if #available(iOS 16.4, *) {
                tab2
            }
        }
    }
    
    var tab1: some View {
        BackportedBottoms()
            .tabItem {
                Image(systemName: "square.bottomhalf.filled")
                Text("Backported")
            }
    }
    
    @available(iOS 16.4, *)
    var tab2: some View {
        NativeBottoms()
            .tabItem {
                Image(systemName: "archivebox.circle")
                Text("Natives")
            }
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
